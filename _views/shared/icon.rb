module Views
  module Shared
    class Icon < Jekyll::Component
      def initialize(icon, css: nil)
        @name = icon
        @css = css
      end

      def view_template
        icon = icons[@name.to_sym]
        return unless icon

        svg style: "width: #{icon.width}px; height: #{icon.height}px;", class: @css do
          render Use.new(@name)
        end
      end
    end

    class Use < Phlex::SVG
      def initialize(name)
        @name = name
      end

      def view_template
        use href: "##{@name}"
      end
    end
  end
end
