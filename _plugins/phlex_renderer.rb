require "phlex"
require "uri"
require "nokogiri"
require "ostruct"
require "active_support/inflector"
require "active_support/core_ext/object/blank"

module Jekyll
  module PhlexRenderer
    def self.render(view_class, site:, page:)
      Jekyll.current_site = site
      Jekyll.current_page = page

      view_class.new.call
    end

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

    def to_s
      PhlexRenderer.render(PhlexRenderer.root_view_class, site: @site, page: @page)
    rescue => e
      raise Liquid::SyntaxError, "Error rendering Phlex view: #{e.message}"
    end
  end
end

Jekyll::Hooks.register :site, :after_init do |site|
  Jekyll::PhlexRenderer.load_all_views
end

Jekyll::Hooks.register :pages, :pre_render do |page, payload|
  payload["render_phlex"] = Jekyll::RenderPhlexDrop.new(site: page.site, page: page)
end
