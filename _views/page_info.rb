module Views
  class PageInfo < Jekyll::Component

    def initialize(format: nil)
      @format = format
    end

    def view_template
      div(
        class: "container group",
        data: stimulus(
          controller: :page_info,
          actions: {
            "app:pageInfoLoaded@window" => :page_info_loaded,
            "app:pageInfoError@window" => :page_info_error
          },
          values: {
            has_error: "false",
            has_data: "false",
            has_favicon: "false",
            format: @format
          }
        )
      ) do
        div class: "hidden gap-2 group-data-[page-info-has-data-value=true]:flex" do
          div class: "relative top-[-1px] browser-ios:top-[1px]" do
            Favicon(
              data: stimulus_item(target: :favicon, for: :page_info)
            )
          end
          div class: "min-w-0 grow" do
            h1 data: stimulus_item(target: :title, for: :page_info), class: "text-700 mb-1 line-clamp-3 font-bold empty:hidden"
            p data: stimulus_item(target: :description, for: :page_info), class: "mb-1 line-clamp-3 empty:hidden"
            p data: stimulus_item(target: :url, for: :page_info), class: "text-500 mb-1 truncate empty:hidden"
          end
        end
      end
    end
  end
end
