module Views
  class PageInfo < Jekyll::Component
    def initialize(format: nil)
      @format = format
    end

    def view_template
      div(
        class: "container group",
        data: {
          controller: "page-info",
          page_info_has_error_value: "false",
          page_info_has_data_value: "false",
          page_info_has_favicon_value: "false",
          page_info_format_value: @format,
          action: "app:pageInfoLoaded@window->page-info#pageInfoLoaded app:pageInfoError@window->page-info#pageInfoError"
        }
      ) do
        div class: "hidden gap-2 group-data-[page-info-has-data-value=true]:flex" do
          div class: "relative top-[-1px] browser-ios:top-[1px]" do
            Favicon(
              data_page_info_target: "favicon"
            )
          end
          div class: "min-w-0 grow" do
            h1 data: { page_info_target: "title" }, class: "text-700 mb-1 line-clamp-3 font-bold empty:hidden"
            p data: { page_info_target: "description" }, class: "mb-1 line-clamp-3 empty:hidden"
            p data: { page_info_target: "url" }, class: "text-500 mb-1 truncate empty:hidden"
          end
        end
      end
    end
  end
end
