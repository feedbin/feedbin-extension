module Views
  module Shared
    class Tab < Jekyll::Component

      def initialize(content: nil, button: nil, &block)
        @content = content
        @button = button
        @block = block
      end

      def view_template
        div(
          data: stimulus_item(
            target: :scroll_container,
            actions: {
              "scroll" => :check_scroll
            },
            for: :app
          ),
          class: "grow min-h-0 overflow-scroll overscroll-y-contain browser-ios:min-h-auto browser-ios:max-h-none"
        ) do
          div class: "px-4 py-4", data: stimulus_item(target: :content_container, for: :app) do
            if @block
              @block.call
            else
              plain @content if @content
            end
          end
        end

        div class: "w-full shrink-0 border-t px-4 py-4 empty:hidden transition group-data-[app-footer-border-value=false]:border-transparent" do
          plain @button if @button
        end

        div(
          data: stimulus_item(target: :footer_spacer, for: :app),
          class: "shrink-0 ease-out transition-[min-height] min-h-[var(--visual-viewport-offset)]"
        )
      end
    end
  end
end
