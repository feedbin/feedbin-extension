module Views
  class Newsletters < Jekyll::Component

    def view_template
      div(
        class: "container group ",
        data: stimulus(
          controller: Controllers::NEWSLETTERS,
          actions: {
            "app:authorized@window" => :new
          },
          values: {
            state: "initial",
            edited: "false",
            address_valid: "true",
            new_address_url: build_url("new_address"),
            create_address_url: build_url("create_address")
          }
        )
      ) do
        # Loading state
        div class: "message hidden group-data-[newsletters-state-value=loading]:flex" do
          Spinner()
          p { "Loading…" }
        end

        # Main tab content
        div(
          data: stimulus_item(
            target: :scroll_container,
            actions: {
              "scroll" => :check_scroll
            },
            for: Controllers::APP
          ),
          class: "grow min-h-0 overflow-scroll overscroll-y-contain browser-ios:min-h-auto browser-ios:max-h-none"
        ) do
          div(class: "px-4 py-4", data: stimulus_item(target: :content_container, for: Controllers::APP)) do
            div class: "flex flex-col gap-4" do
              # Title (shown in initial and success states)
              h1(class: "heading hidden group-data-[newsletters-state-value=initial]:block group-data-[newsletters-state-value=success]:block") { "New Address" }

              # Error message
              Error(content: "", data: stimulus_item(target: :error, for: Controllers::NEWSLETTERS))

              # Success message
              div class: "py-12 hidden group-data-[newsletters-state-value=success]:block" do
                div class: "message" do
                  MessageIcon(type: "success")
                  p { "Address Created" }

                  button(
                    class: "mt-6 inline-flex w-auto items-center justify-center group secondary-button",
                    data: stimulus(controller: Controllers::COPY, actions: {
                      "click" => :copy
                    }, values: {
                      copied: "false",
                      data: ""
                    }).merge(
                      stimulus_item(target: :copy_button, for: Controllers::NEWSLETTERS)
                    )
                  ) do
                    div class: "flex gap-2 items-center" do
                      Icon("copy", css: "fill-400 transition group-data-[copy-copied-value=true]:fill-blue-600")
                      div class: "shrink-0", data: stimulus_item(target: :copy_message, for: Controllers::COPY) do
                        span(class: "hidden group-data-[copy-copied-value=false]:block") { "Copy" }
                        span(class: "hidden group-data-[copy-copied-value=true]:block") { "Copied" }
                      end
                    end
                  end

                  div(class: "-mt-2 text-500 max-w-[90%] min-w-0 truncate", data: stimulus_item(target: :address_output, for: Controllers::NEWSLETTERS)) { "asdf.asdf@feedb.in" }
                end
              end

              # Form (shown in initial state)
              div class: "hidden mb-8 group-data-[newsletters-state-value=initial]:block" do
                form(
                    data: stimulus_item(
                      target: :form,
                      data: {
                        action: "submit->newsletters#submit:prevent submit->newsletters#disable:prevent "
                      },
                      for: Controllers::NEWSLETTERS
                    ),
                  action: build_url("create_address"),
                  method: "POST",
                  class: "flex flex-col gap-4",
                  novalidate: true
                ) do
                  input type: "hidden", name: "verified_token", data: stimulus_item(target: :verified_token_input, for: Controllers::NEWSLETTERS)

                  div do
                    label class: "text-input group/address" do
                      div class: "pl-2 flex items-center justify-center shrink-0 pointer-events-none" do
                        Icon("newsletters", css: "fill-400 transition group-focus-within/address:fill-blue-600")
                      end
                      input(
                        data: stimulus_item(
                          target: :address_input,
                          data: {
                            action: "newsletters#addressInputChanged"
                          },
                          for: Controllers::NEWSLETTERS
                        ),
                        type: "text",
                        name: "address",
                        autocorrect: "off",
                        autocapitalize: "off",
                        spellcheck: "false",
                        maxlength: "40"
                      )
                      div(
                        data: stimulus_item(target: :numbers, for: Controllers::NEWSLETTERS),
                        class: "px-4 border-l border-400 bg-100 flex items-center justify-center shrink-0 pointer-events-none empty:hidden group-data-[newsletters-address-valid-value=false]:hidden"
                      )
                    end
                    div class: "text-500 mt-1 flex min-w-0 gap-4" do
                      div(class: "grow text-600 hidden group-data-[newsletters-address-valid-value=false]:block") { "Invalid Address" }
                      div class: "grow text-600 truncate group-data-[newsletters-address-valid-value=false]:hidden", data: stimulus_item(target: :address_output, for: Controllers::NEWSLETTERS)
                      div(class: "group-data-[newsletters-edited-value=true]:hidden") { "Or choose a custom prefix" }
                    end
                  end

                  label class: "text-input" do
                    input(
                      data: stimulus_item(target: :address_description, for: Controllers::NEWSLETTERS),
                      type: "text",
                      name: "description",
                      placeholder: "Description"
                    )
                  end

                  div class: "flex gap-6 items-center" do
                    div class: "flex flex-col gap-1 grow min-w-0" do
                      div(class: "text-700") { "Default Tag" }
                      div(class: "text-500") { "Newsletters will appear in this tag" }
                    end
                    div class: "shrink-0" do
                      label class: "text-input group/tag max-w-[140px]" do
                        select class: "truncate", name: "newsletter_tag", data: stimulus_item(target: :address_tag, for: Controllers::NEWSLETTERS)
                        div class: "pr-2 absolute inset-y-0 right-0 flex items-center justify-center shrink-0 pointer-events-none" do
                          Icon("caret", css: "fill-400 transition group-focus-within/tag:fill-blue-600")
                        end
                      end
                    end
                  end

                  button(
                    type: "submit",
                    name: "button_action",
                    value: "save",
                    data: stimulus_item(target: :submit_button, for: Controllers::NEWSLETTERS),
                    class: "primary-button mt-4"
                  ) { "Create" }
                end
              end

              # Addresses list
              div class: "flex-col gap-4 hidden group-data-[newsletters-state-value=initial]:flex group-data-[newsletters-state-value=success]:flex" do
                div class: "flex gap-2 justify-between items-baseline" do
                  h1(class: "heading") { "Addresses" }
                  a(class: "text-700", href: build_url("newsletter_settings")) { "Manage ↗" }
                end
                ul data: stimulus_item(target: :address_list, for: Controllers::NEWSLETTERS)
              end
            end
          end
        end

        # Footer spacer
        div(
          data: stimulus_item(target: :footer_spacer, for: Controllers::APP),
          class: "shrink-0 ease-out transition-[min-height] min-h-[var(--visual-viewport-offset)]"
        )

        # Address template
        template data: stimulus_item(target: :address_template, for: Controllers::NEWSLETTERS) do
          li(
            class: "group flex border-b first:border-t",
            data: stimulus(
              controller: Controllers::COPY,
              values: {
                copied: "false",
                data: ""
              },
              data: {
                template: "container"
              }
            )
          ) do
            button(
              class: "text-left grow min-w-0 flex items-center gap-6 cursor-pointer py-4 outline-2 outline-transparent transition focus-visible:outline-blue-400 focus-visible:rounded",
              data: stimulus_item(
                actions: {
                  "click" => :copy
                },
                for: Controllers::COPY
              )
            ) do
              div class: "grow min-w-0" do
                div class: "flex flex-col gap-1 grow min-w-0" do
                  div class: "text-700 truncate", data: { template: "email" }
                  div class: "text-500 empty:hidden", data: { template: "description" }
                end
              end
              div class: "flex gap-2 items-center text-blue-600 group-data-[copy-copied-value=true]:text-blue-700" do
                div class: "shrink-0", data: stimulus_item(target: :copy_message, for: Controllers::COPY) do
                  span(class: "hidden group-data-[copy-copied-value=false]:block") { "Copy" }
                  span(class: "hidden group-data-[copy-copied-value=true]:block") { "Copied" }
                end
                Icon("copy", css: "fill-blue-600 transition group-data-[copy-copied-value=true]:fill-blue-700")
              end
            end
          end
        end

        # Option template
        template data: stimulus_item(target: :option_template, for: Controllers::NEWSLETTERS) do
          option data: { template: "option" }, value: ""
        end
      end
    end
  end
end
