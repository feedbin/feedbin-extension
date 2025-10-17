module Views
  class Newsletters < Jekyll::Component
    def view_template
      div(
        class: "container group ",
        data: {
          controller: "newsletters",
          newsletters_state_value: "initial",
          newsletters_edited_value: "false",
          newsletters_address_valid_value: "true",
          newsletters_new_address_url_value: site.config["urls"]["new_address"],
          newsletters_create_address_url_value: site.config["urls"]["create_address"],
          action: "app:authorized@window->newsletters#new"
        }
      ) do
        # Loading state
        div(class: "message hidden group-data-[newsletters-state-value=loading]:flex") do
          render Shared::Spinner.new
          p { "Loading…" }
        end

        # Main tab content
        div(
          data: {
            app_target: "scrollContainer",
            action: "scroll->app#checkScroll"
          },
          class: "grow min-h-0 overflow-scroll overscroll-y-contain browser-ios:min-h-auto browser-ios:max-h-none"
        ) do
          div(class: "px-4 py-4", data: { app_target: "contentContainer" }) do
            div(class: "flex flex-col gap-4") do
              # Title (shown in initial and success states)
              h1(class: "heading hidden group-data-[newsletters-state-value=initial]:block group-data-[newsletters-state-value=success]:block") { "New Address" }

              # Error message
              render Shared::Error.new(content: "", data_newsletters_target: "error")

              # Success message
              div(class: "py-12 hidden group-data-[newsletters-state-value=success]:block") do
                div(class: "message") do
                  render Shared::MessageIcon.new(type: "success")
                  p { "Address Created" }

                  button(
                    class: "mt-6 inline-flex w-auto items-center justify-center group secondary-button",
                    data: {
                      newsletters_target: "copyButton",
                      action: "click->copy#copy",
                      controller: "copy",
                      copy_copied_value: "false",
                      copy_data_value: ""
                    }
                  ) do
                    div(class: "flex gap-2 items-center") do
                      render Shared::Icon.new(
                        icon: "copy",
                        css_class: "fill-400 transition group-data-[copy-copied-value=true]:fill-blue-600"
                      )
                      div(class: "shrink-0", data: { copy_target: "copyMessage" }) do
                        span(class: "hidden group-data-[copy-copied-value=false]:block") { "Copy" }
                        span(class: "hidden group-data-[copy-copied-value=true]:block") { "Copied" }
                      end
                    end
                  end

                  div(class: "-mt-2 text-500 max-w-[90%] min-w-0 truncate", data: { newsletters_target: "addressOutput" }) { "asdf.asdf@feedb.in" }
                end
              end

              # Form (shown in initial state)
              div(class: "hidden mb-8 group-data-[newsletters-state-value=initial]:block") do
                form(
                  data: {
                    newsletters_target: "form",
                    action: "submit->newsletters#submit:prevent submit->newsletters#disable:prevent "
                  },
                  action: site.config["urls"]["create_address"],
                  method: "POST",
                  class: "flex flex-col gap-4",
                  novalidate: true
                ) do
                  input(type: "hidden", name: "verified_token", data: { newsletters_target: "verifiedTokenInput" })

                  div do
                    label(class: "text-input group/address") do
                      div(class: "pl-2 flex items-center justify-center shrink-0 pointer-events-none") do
                        render Shared::Icon.new(
                          icon: "newsletters",
                          css_class: "fill-400 transition group-focus-within/address:fill-blue-600"
                        )
                      end
                      input(
                        data: {
                          newsletters_target: "addressInput",
                          action: "newsletters#addressInputChanged"
                        },
                        type: "text",
                        name: "address",
                        autocorrect: "off",
                        autocapitalize: "off",
                        spellcheck: "false",
                        maxlength: "40"
                      )
                      div(
                        data: { newsletters_target: "numbers" },
                        class: "px-4 border-l border-400 bg-100 flex items-center justify-center shrink-0 pointer-events-none empty:hidden group-data-[newsletters-address-valid-value=false]:hidden"
                      )
                    end
                    div(class: "text-500 mt-1 flex min-w-0 gap-4") do
                      div(class: "grow text-600 hidden group-data-[newsletters-address-valid-value=false]:block") { "Invalid Address" }
                      div(class: "grow text-600 truncate group-data-[newsletters-address-valid-value=false]:hidden", data: { newsletters_target: "addressOutput" })
                      div(class: "group-data-[newsletters-edited-value=true]:hidden") { "Or choose a custom prefix" }
                    end
                  end

                  label(class: "text-input") do
                    input(
                      data: { newsletters_target: "addressDescription" },
                      type: "text",
                      name: "description",
                      placeholder: "Description"
                    )
                  end

                  div(class: "flex gap-6 items-center") do
                    div(class: "flex flex-col gap-1 grow min-w-0") do
                      div(class: "text-700") { "Default Tag" }
                      div(class: "text-500") { "Newsletters will appear in this tag" }
                    end
                    div(class: "shrink-0") do
                      label(class: "text-input group/tag max-w-[140px]") do
                        select(class: "truncate", name: "newsletter_tag", data: { newsletters_target: "addressTag" })
                        div(class: "pr-2 absolute inset-y-0 right-0 flex items-center justify-center shrink-0 pointer-events-none") do
                          render Shared::Icon.new(
                            icon: "caret",
                            css_class: "fill-400 transition group-focus-within/tag:fill-blue-600"
                          )
                        end
                      end
                    end
                  end

                  button(
                    type: "submit",
                    name: "button_action",
                    value: "save",
                    data: { newsletters_target: "submitButton" },
                    class: "primary-button mt-4"
                  ) { "Create" }
                end
              end

              # Addresses list
              div(class: "flex-col gap-4 hidden group-data-[newsletters-state-value=initial]:flex group-data-[newsletters-state-value=success]:flex") do
                div(class: "flex gap-2 justify-between items-baseline") do
                  h1(class: "heading") { "Addresses" }
                  a(class: "text-700", href: site.config["urls"]["newsletter_settings"]) { "Manage ↗" }
                end
                ul(data: { newsletters_target: "addressList" })
              end
            end
          end
        end

        # Footer spacer
        div(
          data: { app_target: "footerSpacer" },
          class: "shrink-0 ease-out transition-[min-height] min-h-[var(--visual-viewport-offset)]"
        )

        # Address template
        template(data: { newsletters_target: "addressTemplate" }) do
          li(
            class: "group flex border-b first:border-t",
            data: {
              template: "container",
              controller: "copy",
              copy_copied_value: "false",
              copy_data_value: ""
            }
          ) do
            button(
              class: "text-left grow min-w-0 flex items-center gap-6 cursor-pointer py-4 outline-2 outline-transparent transition focus-visible:outline-blue-400 focus-visible:rounded",
              data: { action: "click->copy#copy" }
            ) do
              div(class: "grow min-w-0") do
                div(class: "flex flex-col gap-1 grow min-w-0") do
                  div(class: "text-700 truncate", data: { template: "email" })
                  div(class: "text-500 empty:hidden", data: { template: "description" })
                end
              end
              div(class: "flex gap-2 items-center text-blue-600 group-data-[copy-copied-value=true]:text-blue-700") do
                div(class: "shrink-0", data: { copy_target: "copyMessage" }) do
                  span(class: "hidden group-data-[copy-copied-value=false]:block") { "Copy" }
                  span(class: "hidden group-data-[copy-copied-value=true]:block") { "Copied" }
                end
                render Shared::Icon.new(
                  icon: "copy",
                  css_class: "fill-blue-600 transition group-data-[copy-copied-value=true]:fill-blue-700"
                )
              end
            end
          end
        end

        # Option template
        template(data: { newsletters_target: "optionTemplate" }) do
          option(data: { template: "option" }, value: "")
        end
      end
    end
  end
end
