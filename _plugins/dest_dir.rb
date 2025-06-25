module Jekyll
  class DestDir < Liquid::Tag
    def render(context)
      site = context.registers[:site]
      site.dest
    end
  end
end

Liquid::Template.register_tag('dest_dir', Jekyll::DestDir)
