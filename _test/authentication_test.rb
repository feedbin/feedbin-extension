require_relative "test_helper"

class AuthenticationTest < SystemTest
  def test_valid_login
    visit "/index.html"
    sign_in

    click_tab(:settings)

    text = page.find("[data-settings-target=signedInAs]").text
    assert_equal "example@example.com", text
  end

  def test_invalid_login
    url = build_url("authentication")

    CapybaraMock.stub_request(:post, url)
      .to_return(status: 401)

    visit "/index.html"
    click_button("Sign In")
    text = page.find("[data-authentication-target=error]").text
    assert_equal "Invalid email or password.", text
  end

  def test_server_error
    url = build_url("authentication")
    CapybaraMock.stub_request(:post, url)
      .to_return(status: 500)

    visit "/index.html"
    click_button("Sign In")
    text = page.find("[data-authentication-target=error]").text
    assert_equal "Invalid response: Internal Server Error", text
  end
end