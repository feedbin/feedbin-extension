require "phlex"
require "uri"

module Views
  module Shared
    extend Phlex::Kit
  end
end

module Jekyll
  # Thread-local storage for Jekyll context
  class << self
    def current_site
      Thread.current[:jekyll_site]
    end

    def current_site=(site)
      Thread.current[:jekyll_site] = site
    end

    def current_page
      Thread.current[:jekyll_page]
    end

    def current_page=(page)
      Thread.current[:jekyll_page] = page
    end
  end

  # Base class for all Phlex components
  # Provides access to Jekyll site and page objects via thread-local storage
  class Component < Phlex::HTML
    def self.inherited(subclass)
      super
      # Include Views::Shared kit when a subclass is created
      subclass.include(Views::Shared) if defined?(Views::Shared)
    end

    def initialize(**kwargs)
      super()
    end

    # Access to Jekyll site object
    def site
      Jekyll.current_site
    end

    # Access to Jekyll page object
    def page
      Jekyll.current_page
    end

    # Access to Jekyll configuration
    def config
      site.config
    end

    # Access to site data
    def data
      site.data
    end

    # Access to Jekyll environment (development, production, etc.)
    def environment
      ENV["JEKYLL_ENV"] || "development"
    end

    # Build a full URL from a key in site.config["urls"]
    # @param url_key [String] The key in the urls hash
    # @return [String] The full URL with api_host as the base
    def build_url(url_key)
      base = site.config["api_host"] || ""
      path = site.config.dig("urls", url_key) || ""
      URI.join(base, path).to_s
    end
  end

  module PhlexRenderer
    # Renders a Phlex view class
    # @param view_class [Class] The Phlex view class to render
    # @param site [Jekyll::Site] The Jekyll site object
    # @param page [Jekyll::Page] The Jekyll page object
    # @return [String] The rendered HTML
    def self.render(view_class, site:, page:)
      # Set thread-local Jekyll context
      Jekyll.current_site = site
      Jekyll.current_page = page

      # Render the component
      view_class.new.call
    end

    # Loads all Phlex views from the _views directory
    def self.load_all_views
      views_dir = File.join(Dir.pwd, "_views")
      return unless Dir.exist?(views_dir)

      # Load all .rb files in _views directory (including subdirectories)
      Dir.glob(File.join(views_dir, "**", "*.rb")).sort.each do |view_path|
        load view_path
      end
    end

    # Loads a Phlex view class from the _views directory
    # @param view_name [String] The name of the view file (without .rb extension)
    # @return [Class] The Phlex view class
    def self.load_view(view_name)
      view_path = File.join(Dir.pwd, "_views", "#{view_name}.rb")

      unless File.exist?(view_path)
        raise ArgumentError, "Phlex view not found: #{view_path}"
      end

      # Load the view file
      load view_path

      # Convert snake_case to CamelCase for class name
      class_name = view_name.split('_').map(&:capitalize).join

      # Try to find the class in the Views module first, then in Object
      if defined?(Views) && Views.const_defined?(class_name)
        Views.const_get(class_name)
      elsif Object.const_defined?(class_name)
        Object.const_get(class_name)
      else
        raise NameError, "Could not find Phlex view class: #{class_name} (from #{view_name})"
      end
    end
  end

  # Liquid tag for rendering Phlex views
  # Usage: {% phlex view_name %}
  class PhlexTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @view_name = markup.strip
    end

    def render(context)
      site = context.registers[:site]
      page = context.registers[:page]

      begin
        view_class = PhlexRenderer.load_view(@view_name)
        PhlexRenderer.render(view_class, site: site, page: page)
      rescue => e
        raise Liquid::SyntaxError, "Error rendering Phlex view '#{@view_name}': #{e.message}"
      end
    end
  end
end

Liquid::Template.register_tag('phlex', Jekyll::PhlexTag)

# Load all views at startup
Jekyll::Hooks.register :site, :after_init do |site|
  Jekyll::PhlexRenderer.load_all_views
end
