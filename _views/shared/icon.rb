module Views
  module Shared
    class Icon < Jekyll::Component
      def initialize(icon, css: nil)
        @name = icon
        @css = css
      end

      def view_template
        icon = site.config["icons"][@name.to_sym]
        raise Exception.new("Unknown icon #{@name}") unless icon

        svg class: @css, style: { width: "#{icon.width}px", height: "#{icon.height}px" } do
          render Use.new(@name)
        end
      end
    end

    class Use < Phlex::SVG
      def initialize(name)
        @name = name
      end

      def view_template
        use href: "#" + @name
      end
    end
  end
end
