module Views
  module Shared
    class Nav < Jekyll::Component
      def view_template
        div class: "hidden shrink-0 p-4 border-b transition group-data-[app-header-border-value=false]:border-transparent group-data-[app-authorized-value=true]:flex" do
          ul class: "flex rounded-[7px] bg-100 w-full p-1" do
            data["tabs"].each do |tab|
              item(tab)
            end
          end
        end
      end

      def item(tab)
        css = "
          flex basis-full relative
          before:transition before:block before:h-[16px] before:w-[1px] before:bg-300 before:absolute
          before:left-0 before:top-[50%] before:translate-[-50%] has-checked:before:opacity-0 first:before:opacity-0
        "
        li data: { tabs_target: "tabContainer" }, class: [(css), ("is-native:hidden basis-auto!" if tab["id"] == "tab-settings")] do
          label class: "text-500 fill-500 flex grow cursor-pointer items-center justify-center gap-2 rounded-[4px] px-3 py-2 whitespace-nowrap outline-2 outline-offset-1 outline-transparent transition has-checked:text-700 has-checked:fill-700 has-checked:bg-0 has-checked:shadow-sm has-focus-visible:outline-blue-400 pointer-fine:hover:text-700 pointer-fine:hover:fill-700" do
            render Icon.new(icon: tab["icon"])
            plain " #{tab['title']}"

            input name: "tab", type: "radio", class: "sr-only", value: tab["id"], data: { tabs_target: "tab", action: "change->tabs#separator change->tabs#save" }
          end
        end
      end
    end
  end
end
