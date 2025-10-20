module Views
  class Index < Jekyll::Component
    STIMULUS_CONTROLLER = :app
    TABS_CONTROLLER = :tabs

    def view_template
      doctype
      html_data = stimulus(
        controller: STIMULUS_CONTROLLER,
        actions: {
          "helpers:checkAuth@window" => :authorize,
          "visual-viewport:change@window" => :delayed_check_scroll
        },
        values: {
          authorized: "false",
          browser: "chrome",
          native: "false",
          header_border: "false",
          footer_border: "false"
        },
        data: {
          controller: "app visual-viewport"
        }
      )
      html class: "group", data: html_data do
        head do
          meta charset: "UTF-8"
          meta name: "viewport", content: "width=device-width, initial-scale=1.0"
          title { "Feedbin Subscribe & Save" }
          link rel: "stylesheet", href: "assets/css/wrapper.css"

          script src: "assets/javascript/lib/extension-polyfill.js"
          script src: "assets/javascript/lib/browser-polyfill.js"
          script src: "assets/javascript/application.js", type: "module"
        end

        body class: "group flex flex-col bg-0 cursor-default antialiased select-none text-600 text-sm! leading-[1.4] w-[456px] h-[500px] [text-size-adjust:none] is-native:text-base! browser-ios:h-screen browser-ios:w-screen browser-ios:max-h-dvh browser-ios:max-w-screen" do
          div data: stimulus(controller: TABS_CONTROLLER, actions: {
            "app:authorized@window" => :select_tab,
            "app:notAuthorized@window" => :select_tab
          }), class: "container group" do
            Nav()

            div class: "hidden container group-has-[[value=tab-add]:checked]:flex" do
              render Add.new
            end

            div class: "hidden container group-has-[[value=tab-save]:checked]:flex" do
              render Save.new
            end

            div class: "hidden container group-has-[[value=tab-newsletters]:checked]:flex" do
              render Newsletters.new
            end

            div class: "hidden container group-has-[[value=tab-settings]:checked]:flex" do
              render Settings.new
            end
          end
          svg class: "hidden" do
            render IconSymbols.new(site.config["icons"])
          end
        end
      end
    end
  end

  # Phlex::SVG component for rendering icon symbol definitions
  class IconSymbols < Phlex::SVG
    def initialize(icons)
      @icons = icons
    end

    def view_template
      @icons.each do |_, icon|
        symbol id: icon.name, viewBox: "0 0 #{icon.width} #{icon.height}" do
          raw safe(icon.markup)
        end
      end
    end
  end
end
