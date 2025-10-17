module Views
  class ExampleCard < Jekyll::Component
    def view_template
      div(class: "card") do
        h2(class: "card-title") { "Example Card" }
        p(class: "card-content") do
          plain "Site title: "
          pp site.data
          strong { site.config["urls"]["authentication"] || "No title set" }
        end
        p(class: "card-info") do
          plain "Current page: "
          strong { page["url"] || "/" }
        end
        p(class: "card-info") do
          plain "environment: "
          strong { environment }
        end
      end
    end
  end
end
