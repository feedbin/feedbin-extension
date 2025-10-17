module Views
  class Index < Jekyll::Component
    def view_template
      doctype
      data = {
        controller: "app visual-viewport",
        app_authorized_value: "false",
        app_browser_value: "chrome",
        app_native_value: "false",
        app_header_border_value: "false",
        app_footer_border_value: "false",
        action: "helpers:checkAuth@window->app#authorize visual-viewport:change@window->app#delayedCheckScroll"
      }
      html(class: "group", data: data) do
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
          div data: {controller: "tabs", action: "app:authorized@window->tabs#selectTab app:notAuthorized@window->tabs#selectTab"}, class: "container group" do
            # TODO: {% include shared/nav.html %}

            div(class: "hidden container group-has-[[value=tab-add]:checked]:flex") do
              # TODO: {% include add.html %}
            end

            div(class: "hidden container group-has-[[value=tab-save]:checked]:flex") do
              # TODO: {% include save.html %}
            end

            div(class: "hidden container group-has-[[value=tab-newsletters]:checked]:flex") do
              # TODO: {% include newsletters.html %}
            end

            div(class: "hidden container group-has-[[value=tab-settings]:checked]:flex") do
              # TODO: {% include settings.html %}
            end
          end

          svg(class: "hidden") do
            comment { " TODO: Icon symbols from site.data.icons " }
          end
        end
      end
    end
  end
end
