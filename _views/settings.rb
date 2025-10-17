module Views
  class Settings < Jekyll::Component
    def view_template
      # Signed in state
      div(
        data: {
          controller: "settings",
          action: "helpers:checkAuth@window->settings#userData"
        },
        class: "message hidden group-data-[app-authorized-value=true]:flex"
      ) do
        Icon("logo", css: "shrink-0")
        p do
          plain "Signed in as "
          strong class: "text-700 font-medium", data: { settings_target: "signedInAs" }
        end

        button(
          data: {
            action: "click->settings#signOut:prevent",
            settings_target: "signOutButton"
          },
          class: "cursor-pointer block text-blue-600"
        ) { "Sign Out" }
      end

      # Not signed in state
      div(
        class: "group container hidden group-data-[app-authorized-value=false]:flex",
        data: {
          controller: "authentication",
          authentication_loading_value: "false",
          authentication_ios_auth_value: "true"
        }
      ) do
        # iOS message
        div class: "message hidden browser-ios:flex" do
          p(class: "hidden group-data-[authentication-ios-auth-value=true]:block") { "Signing in…" }
          p class: "hidden group-data-[authentication-ios-auth-value=false]:block" do
            a href: "feedbin://", class: "p-4 block" do
              plain "Sign in with "
              span(class: "text-blue-600") { "Feedbin" }
              plain " to continue"
            end
          end
        end

        # Sign in form
        form(
          novalidate: true,
          action: build_url("authentication"),
          method: "POST",
          class: "container group is-native:hidden",
          data: {
            action: "submit->authentication#submit:prevent",
            authentication_target: "form"
          }
        ) do
          # Scroll container with content
          div(
            data: {
              app_target: "scrollContainer",
              action: "scroll->app#checkScroll"
            },
            class: "grow min-h-0 overflow-scroll overscroll-y-contain browser-ios:min-h-auto browser-ios:max-h-none"
          ) do
            div(class: "px-4 py-4", data: { app_target: "contentContainer" }) do
              div class: "hidden flex-col items-stretch group-data-[app-authorized-value=false]:flex" do
                div class: "flex items-center justify-center py-6 pb-8" do
                  Icon("logo-full", css: "shrink-0")
                end

                Error(content: "", data_authentication_target: "error")

                div class: "flex flex-col gap-2" do
                  label(class: "block", for: "email_input") { "Email" }
                  label class: "text-input mb-4" do
                    input(
                      id: "email_input",
                      type: "text",
                      name: "email",
                      data: { authentication_target: "email" },
                      autocorrect: "off",
                      autocapitalize: "off",
                      spellcheck: "false",
                      required: true,
                      tabindex: "1"
                    )
                  end

                  div class: "flex items-baseline justify-between" do
                    label(class: "block", for: "password_input") { "Password" }
                    a(class: "text-500 pointer-fine:hover:underline", href: build_url("password_reset")) { "Forgot your password?" }
                  end
                  label class: "text-input" do
                    input(
                      id: "password_input",
                      type: "password",
                      name: "password",
                      data: { authentication_target: "password" },
                      tabindex: "2"
                    )
                  end
                end
              end
            end
          end

          # Button footer
          div class: "w-full shrink-0 border-t px-4 py-4 empty:hidden transition group-data-[app-footer-border-value=false]:border-transparent" do
            button(
              data: { authentication_target: "submitButton" },
              type: "submit",
              class: "primary-button hidden group-data-[app-authorized-value=false]:block"
            ) do
              span(class: "hidden group-data-[authentication-loading-value=false]:block") { " Sign In " }
              span(class: "hidden group-data-[authentication-loading-value=true]:block") { " Loading… " }
            end
          end

          # Footer spacer
          div(
            data: { app_target: "footerSpacer" },
            class: "shrink-0 ease-out transition-[min-height] min-h-[var(--visual-viewport-offset)]"
          )
        end
      end
    end
  end
end
