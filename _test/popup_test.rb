require_relative "test_helper"

class PopupTest < SystemTest
  def test_invalid_login
    url = build_url("authentication")

    CapybaraMock.stub_request(:post, url)
      .to_return(status: 401, body: {page_token: "token"}.to_json)

    visit "/index.html"
    click_button("Sign In")
    assert_equal "Invalid email or password.", page.find(:css, "[data-settings-target=error]").text
  end

  def test_valid_login
  end

  def test_server_error
  end
end