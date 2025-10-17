module Views
  module Shared
    class Favicon < Jekyll::Component
      def initialize(**attributes)
        @attributes = attributes
      end

      def view_template
        div(
          data: {
            controller: "favicon",
            favicon_has_favicon_value: "false"
          },
          class: "group flex shrink-0 items-center justify-center h-[20px] w-[20px] rounded-xs dark:data-[favicon-has-favicon-value=true]:bg-white",
          **@attributes
        ) do
          render Icon.new(
            icon: "feed",
            css_class: "fill-600 hidden group-data-[favicon-has-favicon-value=false]:block"
          )
          img data: { favicon_target: "favicon" }, class: "hidden max-h-[16px] max-w-[16px] group-data-[favicon-has-favicon-value=true]:block"
        end
      end
    end
  end
end
