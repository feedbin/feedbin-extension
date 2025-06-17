require_relative "test_helper"

class SettingsTest < SystemTest
  def test_valid_login
    url = build_url("authentication")
    CapybaraMock.stub_request(:post, url)
      .to_return(body: {page_token: "token"}.to_json)
    visit "/index.html"
    click_button("Sign In")
  end

  def test_invalid_login
    url = build_url("authentication")

    CapybaraMock.stub_request(:post, url)
      .to_return(status: 401)

    visit "/index.html"
    click_button("Sign In")
    text = page.find(:css, "[data-settings-target=error]").text
    assert_equal "Invalid email or password.", text
  end

  def test_server_error
    url = build_url("authentication")
    CapybaraMock.stub_request(:post, url)
      .to_return(status: 500)

    visit "/index.html"
    click_button("Sign In")
    text = page.find(:css, "[data-settings-target=error]").text
    assert_equal "Invalid response: Internal Server Error", text
  end
end