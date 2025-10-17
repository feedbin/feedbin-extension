module Views
  module Shared
    class Icon < Jekyll::Component
      def initialize(icon:, css_class: nil)
        @icon_name = icon
        @css_class = css_class
      end

      def view_template
        icon_data = data["icons"][@icon_name]
        return unless icon_data

        svg(
          style: "width: #{icon_data['width']}px; height: #{icon_data['height']}px;",
          class: @css_class
        ) do
          render IconUse.new(@icon_name)
        end
      end
    end

    # Phlex::SVG component for rendering SVG use element
    class IconUse < Phlex::SVG
      def initialize(icon_name)
        @icon_name = icon_name
      end

      def view_template
        whitespace
        use(href: "##{@icon_name}")
      end
    end
  end
end
