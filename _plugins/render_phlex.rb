require "phlex"

module Jekyll
  class RenderPhlex < Liquid::Tag

    def initialize(...)
      super
    end

    def render(context)
      ::Views::Index.new.call
    end
  end
end

Liquid::Template.register_tag("render_phlex", Jekyll::RenderPhlex)

# load all views
Jekyll::Hooks.register :site, :after_init do |site|
  views_dir = File.join(Dir.pwd, "_views")
  Dir.glob(File.join(views_dir, "**", "*.rb")).sort.each do |view_path|
    load view_path
  end
end
