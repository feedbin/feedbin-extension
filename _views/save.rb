module Views
  class Save < Jekyll::Component
    def view_template
      div(
        class: "container group",
        data: {
          controller: "save",
          action: "app:pageInfoError@window->save#loadError keydown@document->save#keydown",
          save_state_value: "initial"
        }
      ) do
        form(
          class: "container",
          data: {
            action: "submit->save#submit:prevent",
            save_target: "form"
          },
          action: build_url("save"),
          method: "POST",
          novalidate: true
        ) do
          # Success message
          div(class: "message flex hidden group-data-[save-state-value=saved]:flex") do
            render Shared::MessageIcon.new(type: "success")
            p { "Page Saved" }
          end

          # Error message
          div(class: "message flex hidden group-data-[save-state-value=error]:flex") do
            render Shared::MessageIcon.new(type: "error")
            p(data: { save_target: "error" })
          end

          # Load error message
          div(class: "message flex hidden group-data-[save-state-value=loadError]:flex") do
            render Shared::MessageIcon.new(type: "neutral", icon: "save")
            p { "Page cannot be saved" }
          end

          # Main form container
          div(class: "hidden container group-data-[save-state-value=initial]:flex group-data-[save-state-value=loading]:flex") do
            # Scroll container with content
            div(
              data: {
                app_target: "scrollContainer",
                action: "scroll->app#checkScroll"
              },
              class: "grow min-h-0 overflow-scroll overscroll-y-contain browser-ios:min-h-auto browser-ios:max-h-none"
            ) do
              div(class: "px-4 py-4", data: { app_target: "contentContainer" }) do
                render PageInfo.new(format: "save")
              end
            end

            # Button footer
            div(class: "w-full shrink-0 border-t px-4 py-4 empty:hidden transition group-data-[app-footer-border-value=false]:border-transparent") do
              button(
                data: { save_target: "submitButton" },
                type: "submit",
                class: "primary-button"
              ) do
                span(class: "hidden group-data-[save-state-value=initial]:block") { "Save" }
                span(class: "hidden group-data-[save-state-value=loading]:block") { "Saving…" }
              end
            end

            # Footer spacer
            div(
              data: { app_target: "footerSpacer" },
              class: "shrink-0 ease-out transition-[min-height] min-h-[var(--visual-viewport-offset)]"
            )
          end
        end
      end
    end
  end
end
