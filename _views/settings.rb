module Views
  class Settings < Jekyll::Component
    def view_template
      # Signed in state
      signed_in

      # Not signed in state
      signed_out
    end

    def signed_out
      div(class: "group container hidden group-data-[app-authorized-value=false]:flex", data: stimulus( controller: Controllers::AUTHENTICATION, values: { loading: "false", ios_auth: "true" } ) ) do
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
        form novalidate: true, action: build_url("authentication"), method: "POST", class: "container group is-native:hidden", data: stimulus_item(target: :form, actions: { "submit" => :"submit:prevent" }, for: Controllers::AUTHENTICATION ) do
          # Scroll container with content
          div data: stimulus_item(target: :scroll_container, actions: { "scroll" => :check_scroll }, for: Controllers::APP ), class: "grow min-h-0 overflow-scroll overscroll-y-contain browser-ios:min-h-auto browser-ios:max-h-none" do
            div(class: "px-4 py-4", data: stimulus_item(target: :content_container, for: Controllers::APP)) do
              div class: "hidden flex-col items-stretch group-data-[app-authorized-value=false]:flex" do
                div class: "flex items-center justify-center py-6 pb-8" do
                  Icon("logo-full", css: "shrink-0")
                end

                Error(content: "", data: stimulus_item(target: :error, for: Controllers::AUTHENTICATION))

                div class: "flex flex-col gap-2" do
                  label(class: "block", for: "email_input") { "Email" }
                  label class: "text-input mb-4" do
                    input(
                      id: "email_input",
                      type: "text",
                      name: "email",
                      data: stimulus_item(target: :email, for: Controllers::AUTHENTICATION),
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
                      data: stimulus_item(target: :password, for: Controllers::AUTHENTICATION),
                      tabindex: "2"
                    )
                  end
                end
              end
            end
          end

          # Button footer
          div class: "w-full shrink-0 border-t px-4 py-4 empty:hidden transition group-data-[app-footer-border-value=false]:border-transparent" do
            button data: stimulus_item(target: :submit_button, for: Controllers::AUTHENTICATION), type: "submit", class: "primary-button hidden group-data-[app-authorized-value=false]:block" do
              span(class: "hidden group-data-[authentication-loading-value=false]:block") { " Sign In " }
              span(class: "hidden group-data-[authentication-loading-value=true]:block") { " Loading… " }
            end
          end

          # Footer spacer
          div data: stimulus_item(target: :footer_spacer, for: Controllers::APP), class: "shrink-0 ease-out transition-[min-height] min-h-[var(--visual-viewport-offset)]"
        end
      end
    end

    def signed_in
      div data: stimulus( controller: Controllers::SETTINGS, actions: { "helpers:checkAuth@window" => :user_data } ), class: "message hidden group-data-[app-authorized-value=true]:flex" do
        Icon("logo", css: "shrink-0")

        p do
          plain "Signed in as "
          strong class: "text-700 font-medium", data: stimulus_item(target: :signed_in_as, for: Controllers::SETTINGS)
        end

        button data: stimulus_item( target: :sign_out_button, actions: { "click" => :"sign_out:prevent" }, for: Controllers::SETTINGS ), class: "cursor-pointer block text-blue-600" do
          "Sign Out"
        end
      end

    end
  end
end
