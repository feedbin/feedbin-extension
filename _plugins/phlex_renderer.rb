require "phlex"

module Jekyll
  # Base class for all Phlex components
  # Provides access to Jekyll site and page objects
  class Component < Phlex::HTML
    attr_reader :site, :page

    def initialize(site:, page:)
      @site = site
      @page = page
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
  end

  module PhlexRenderer
    # Renders a Phlex view class
    # @param view_class [Class] The Phlex view class to render
    # @param site [Jekyll::Site] The Jekyll site object
    # @param page [Jekyll::Page] The Jekyll page object
    # @return [String] The rendered HTML
    def self.render(view_class, site:, page:)
      view_class.new(site: site, page: page).call
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
