require "phlex"
require "uri"
require "nokogiri"
require "ostruct"
require "active_support/inflector"
require "active_support/core_ext/object/blank"

module Views
  module Shared
    extend Phlex::Kit
  end
end

module Jekyll
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

  class Component < Phlex::HTML
    include ::Views::Shared

    def site
      Jekyll.current_site
    end

    def page
      Jekyll.current_page
    end

    # Access to Jekyll environment (development, production, etc.)
    def environment
      ENV["JEKYLL_ENV"] || "development"
    end

    # Build a full URL from a key in site.config["urls"]
    # @param url_key [String] The key in the urls hash
    # @return [String] The full URL with api_host as the base
    def build_url(url_key)
      base = site.config["api_host"]
      path = site.config.dig("urls", url_key)
      URI.join(base, path).to_s
    end

    def stimulus(controller:, actions: {}, values: {}, outlets: {}, classes: {}, data: {})
      stimulus_controller = controller.to_s.dasherize

      action = actions.map do |event, function|
        "#{event}->#{stimulus_controller}##{function.to_s.camelize(:lower)}"
      end.join(" ").presence

      values.transform_keys! do |key|
        [controller, key, "value"].join("_").to_sym
      end

      outlets.transform_keys! do |key|
        [controller, key, "outlet"].join("_").to_sym
      end

      classes.transform_keys! do |key|
        [controller, key, "class"].join("_").to_sym
      end

      { controller: stimulus_controller, action: }.merge!({ **values, **outlets, **classes, **data})
    end

    def stimulus_item(target: nil, actions: {}, params: {}, data: {}, for:)
      stimulus_controller = binding.local_variable_get(:for).to_s.dasherize

      action = actions.map do |event, function|
        "#{event}->#{stimulus_controller}##{function.to_s.camelize(:lower)}"
      end.join(" ").presence

      params.transform_keys! do |key|
        :"#{binding.local_variable_get(:for)}_#{key}_param"
      end

      defaults = { **params, **data }

      if action
        defaults[:action] = action
      end

      if target
        defaults[:"#{binding.local_variable_get(:for)}_target"] = target.to_s.camelize(:lower)
      end

      defaults
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

    def self.root_view_class
      return ::Views::Index if defined?(::Views::Index)

      raise NameError, "Could not find root Phlex view class Views::Index. Ensure _views/index.rb defines it."
    end
  end

  class RenderPhlexDrop < Liquid::Drop
    def initialize(site:, page:)
      @site = site
      @page = page
    end

    def to_liquid
      to_s
    end

    def to_s
      PhlexRenderer.render(PhlexRenderer.root_view_class, site: @site, page: @page)
    rescue => e
      raise Liquid::SyntaxError, "Error rendering Phlex view: #{e.message}"
    end
  end
end

# Load all views at startup
Jekyll::Hooks.register :site, :after_init do |site|
  Jekyll::PhlexRenderer.load_all_views
end

Jekyll::Hooks.register :pages, :pre_render do |page, payload|
  payload["render_phlex"] = Jekyll::RenderPhlexDrop.new(site: page.site, page: page)
end
