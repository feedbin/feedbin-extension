require_relative "test_helper"

class PopupTest < SystemTest
  def test_popup_loads
    CapybaraMock.stub_request(:get, "https://example.com/settings")
      .to_return(body: {amount: "Hello"}.to_json)

    visit "/index.html"
    click_button("Sign In")
    puts "--------------"
    puts page.find(:css, "[data-settings-target=results]").text
    puts "--------------"
    assert_equal "Feedbin Subscribe & Save", page.title
  end
end