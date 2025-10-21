module Views
  module Shared
    class Favicon < Jekyll::Component

      def initialize(**attributes)
        @attributes = attributes
      end

      def view_template
        container = mix(
          {
            data: stimulus(
              controller: Controllers::FAVICON,
              values: {
                has_favicon: "false"
              }
            ),
            class: "group flex shrink-0 items-center justify-center h-[20px] w-[20px] rounded-xs dark:data-[favicon-has-favicon-value=true]:bg-white",
          },
          @attributes
        )
        div **container do
          Icon("feed", css: "fill-600 hidden group-data-[favicon-has-favicon-value=false]:block")
          img data: stimulus_item(target: :favicon, for: Controllers::FAVICON), class: "hidden max-h-[16px] max-w-[16px] group-data-[favicon-has-favicon-value=true]:block"
        end
      end
    end
  end
end
