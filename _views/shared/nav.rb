module Views
  module Shared
    class Nav < Jekyll::Component

      def view_template
        div class: "hidden shrink-0 p-4 border-b transition group-data-[app-header-border-value=false]:border-transparent group-data-[app-authorized-value=true]:flex" do
          ul class: "flex rounded-[7px] bg-100 w-full p-1" do
            tabs.each do |tab|
              item(tab)
            end
          end
        end
      end

      def item(tab)
        container_css = "
          flex basis-full relative
          before:transition before:block before:h-[16px] before:w-[1px] before:bg-300 before:absolute
          before:left-0 before:top-[50%] before:translate-[-50%] has-checked:before:opacity-0 first:before:opacity-0
        "
        li data: stimulus_item(target: :tab_container, for: :tabs), class: [(container_css), ("is-native:hidden basis-auto!" if tab[:id] == "tab-settings")] do
          item_css = "
            text-500 fill-500 flex grow cursor-pointer items-center justify-center gap-2 rounded-[4px] px-3 py-2 whitespace-nowrap
            outline-2 outline-offset-1 outline-transparent transition
            has-checked:text-700 has-checked:fill-700 has-checked:bg-0 has-checked:shadow-sm has-focus-visible:outline-blue-400
            pointer-fine:hover:text-700 pointer-fine:hover:fill-700
          "
          label class: item_css do
            Icon(tab[:icon])
            plain " #{tab[:title]}"

            input name: "tab", type: "radio", class: "sr-only", value: tab[:id], data: stimulus_item(
              target: :tab,
              data: {
                action: "change->tabs#separator change->tabs#save"
              },
              for: :tabs
            )
          end
        end
      end

      def tabs
        [
          {
            title: "Add Feed",
            id: "tab-add",
            icon: "add"
          },
          {
            title: "Save Page",
            id: "tab-save",
            icon: "save"
          },
          {
            title: "Newsletters",
            id: "tab-newsletters",
            icon: "newsletters"
          },
          {
            title: "",
            id: "tab-settings",
            icon: "settings"
          }
        ]
      end
    end
  end
end
