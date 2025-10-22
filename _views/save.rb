module Views
  class Save < Jekyll::Component

    def view_template
      div class: "container group", data: stimulus(controller: Controllers::SAVE, actions: { "app:pageInfoError@window" => :load_error, "keydown@document" => :keydown }, values: { state: "initial" }) do
        form class: "container", data: stimulus_item( target: :form, actions: { "submit" => :"submit:prevent" }, for: Controllers::SAVE ), action: build_url("save"), method: "POST", novalidate: true do
          # Success message
          div class: "message flex hidden group-data-[save-state-value=saved]:flex" do
            MessageIcon(type: "success")
            p { "Page Saved" }
          end

          # Error message
          div class: "message flex hidden group-data-[save-state-value=error]:flex" do
            MessageIcon(type: "error")
            p data: stimulus_item(target: :error, for: Controllers::SAVE)
          end

          # Load error message
          div class: "message flex hidden group-data-[save-state-value=loadError]:flex" do
            MessageIcon(type: "neutral", icon: "save")
            p { "Page cannot be saved" }
          end

          # Main form container
          div class: "hidden container group-data-[save-state-value=initial]:flex group-data-[save-state-value=loading]:flex" do
            # Scroll container with content
            div data: stimulus_item( target: :scroll_container, actions: { "scroll" => :check_scroll }, for: Controllers::APP ), class: "grow min-h-0 overflow-scroll overscroll-y-contain browser-ios:min-h-auto browser-ios:max-h-none" do
              div(class: "px-4 py-4", data: stimulus_item(target: :content_container, for: Controllers::APP)) do
                render PageInfo.new(format: "save")
              end
            end

            # Button footer
            div class: "w-full shrink-0 border-t px-4 py-4 empty:hidden transition group-data-[app-footer-border-value=false]:border-transparent" do
              button data: stimulus_item(target: :submit_button, for: Controllers::SAVE), type: "submit", class: "primary-button" do
                span(class: "hidden group-data-[save-state-value=initial]:block") { "Save" }
                span(class: "hidden group-data-[save-state-value=loading]:block") { "Saving…" }
              end
            end

            # Footer spacer
            div data: stimulus_item(target: :footer_spacer, for: Controllers::APP), class: "shrink-0 ease-out transition-[min-height] min-h-[var(--visual-viewport-offset)]"
          end
        end
      end
    end
  end
end
