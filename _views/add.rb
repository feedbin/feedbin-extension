module Views
  class Add < Jekyll::Component

    def view_template
      controller = stimulus(
        controller: :add,
        actions: {
          "app:pageInfoLoaded@window" => :search,
          "app:pageInfoError@window" => :no_feeds
        },
        values: {
          state: "initial",
          search_url: build_url("find")
        }
      )
      div(class: "container group", data: controller) do
        div class: "message hidden group-data-[add-state-value=initial]:flex", data: stimulus_item( actions: { "click" => :search }, for: :add) do
          Spinner()
          p { "Searching for Feeds…" }
        end

        # Error Message
        div class: "message hidden group-data-[add-state-value=error]:flex" do
          MessageIcon(type: "neutral", icon: "search")
          p data: stimulus_item(target: :error, for: :add), class: "text-center"
        end

        # Success Message
        div class: "message flex hidden group-data-[add-state-value=success]:flex" do
          MessageIcon(type: "success")
          p { "Subscribed" }
        end

        # Subscribe form
        subscribe_form

        templates
      end
    end

    def subscribe_form
      form data: stimulus_item(target: :subscribe_form, actions: { "submit" => :"subscribe:prevent" }, for: :add), action: build_url("subscribe"), class: "hidden container group-data-[add-state-value=hasResults]:flex", novalidate: true, method: "POST" do
        div data: stimulus_item(target: :scroll_container, actions: { "scroll" => :check_scroll }, for: :app), class: "grow min-h-0 overflow-scroll overscroll-y-contain browser-ios:min-h-auto browser-ios:max-h-none" do
          div class: "px-4 py-4", data: stimulus_item(target: :content_container, for: :app) do
            div class: "flex flex-col gap-4" do
              h1 class: "heading" do
                plain "Feed"
                span(class: "group-data-[add-results-count-value=1]:hidden") { "s" }
              end

              div class: "flex flex-col gap-4", data: stimulus_item(target: :feed_results, for: :add)

              h1(class: "heading") { "Tags" }

              label class: "text-input" do
                input(
                  type: "text",
                  name: "tags[]",
                  class: "placeholder:text-600 focus-visible:placeholder:text-500 cursor-pointer border-input text-center placeholder:font-medium focus-visible:cursor-text focus-visible:border-blue-600 focus-visible:text-left focus-visible:placeholder:font-normal",
                  placeholder: "+ New Tag"
                )
              end
              div data: stimulus_item(target: :tag_results, for: :add), class: "flex flex-col gap-2 empty:hidden"
            end
          end
        end

        # Button
        div class: "w-full shrink-0 border-t px-4 py-4 empty:hidden transition group-data-[app-footer-border-value=false]:border-transparent" do
          button data: stimulus_item(target: :submit_button, for: :add), type: "submit", class: "primary-button" do
            span(class: "group-data-[add-state-value=loading]:hidden") { "Subscribe" }
            span(class: "hidden group-data-[add-state-value=loading]:block") { "Subscribing…" }
          end
        end

        # Footer spacer
        div data: stimulus_item(target: :footer_spacer, for: :app), class: "shrink-0 ease-out transition-[min-height] min-h-[var(--visual-viewport-offset)]"
      end
    end

    def templates
      # feed template
      template data: stimulus_item(target: :feed_template, for: :add) do
        div class: "flex" do
          input type: "hidden", data: { template: "url" }
          label class: "flex h-[40px] items-center pr-2" do
            input type: "hidden", value: "0", data: { template: "checkbox_dummy" }
            Checkbox(data: stimulus_item( target: :checkbox, actions: { "change" => :count_selected }, data: { template: "checkbox" }, for: :add ), value: "1")
          end
          div class: "min-w-0 grow" do
            label class: "text-input" do
              div class: "pl-2 flex items-center justify-center shrink-0 pointer-events-none" do
                Favicon(
                  data: stimulus_item(target: :favicon, for: :add)
                )
              end
              input type: "text", data: { template: "feed_input" }
              div data: { template: "subscribed_notice" }, class: "pr-2 flex items-center justify-center shrink-0 pointer-events-none text-green-600 text-xs hidden" do
                "✓ Already Subscribed"
              end
            end
            div class: "text-500 mt-1 flex min-w-0 gap-4" do
              div class: "grow truncate", data: { template: "display_url" }
              div class: "shrink-0", data: { template: "volume" }
            end
          end
        end
      end

      # Tag template
      template data: stimulus_item(target: :tag_template, for: :add) do
        label class: "group/checkbutton flex min-w-0 cursor-pointer items-center gap-3 rounded border dark:border-200 p-3 transition -outline-offset-1 outline-3 outline-transparent has-checked:border-600 has-checked:outline-600" do
          Checkbox(data_template: "checkbox", name: "tags[]")
          div class: "grow truncate", data: { template: "label" }
          Icon("tag", css: "shrink-0 fill-400 group-has-checked/checkbutton:fill-700")
        end
      end
    end
  end
end
