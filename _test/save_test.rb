require_relative "test_helper"

class SaveTest < SystemTest
  def test_site_info_presence
    visit "/index.html"

    sign_in

    click_tab(:save)

    assert_equal "Title", page.find("[data-page-info-target=title]").text
    assert_equal "Description", page.find("[data-page-info-target=description]").text
    assert_equal "daringfireball.net", page.find("[data-page-info-target=url]").text
  end

  def test_site_info_error
    visit "/index.html"

    page.execute_script("window.mockNoTabsFound = true;")

    sign_in

    click_tab(:save)

    assert page.has_css?("[data-page-info-has-error-value=true]")
    assert page.has_text?("Error loading extension")
  end

  def test_save_success
    body = { id: 123, url: "http://daringfireball.net" }

    CapybaraMock.stub_request(:post, build_url("save"))
      .to_return(body: body.to_json)

    visit "/index.html"
    sign_in
    click_tab(:save)

    # Initial button state
    save_button = page.find("[data-save-target='submitButton']")
    assert_equal "Send", save_button.text
    assert_equal false, save_button.disabled?

    # Click save button
    save_button.click

    # Verify button changes to "Saved" and is disabled
    assert page.has_text?("Page Saved")

    # Verify no error is shown
    error_element = page.find("[data-save-target='error']", visible: :all)
    assert_equal "", error_element.text
  end

  def test_save_server_error
    CapybaraMock.stub_request(:post, build_url("save"))
      .to_return(status: 500, body: "Internal Server Error")

    visit "/index.html"
    sign_in
    click_tab(:save)

    # Click save button
    save_button = page.find("[data-save-target='submitButton']")
    save_button.click

    # Verify error is displayed
    error_element = page.find("[data-save-target='error']", visible: :all)
    assert page.has_text?("Error Saving Page: Internal Server Error")
  end

  def test_save_unauthorized_error
    CapybaraMock.stub_request(:post, build_url("save"))
      .to_return(status: 401, body: "Unauthorized")

    visit "/index.html"
    sign_in
    click_tab(:save)

    # Click save button
    save_button = page.find("[data-save-target='submitButton']")
    save_button.click

    # Verify error is displayed
    error_element = page.find("[data-save-target='error']", visible: :all)
    assert page.has_text?("Error Saving Page: Unauthorized")
  end

  def test_save_network_error
    # Simulate network failure by not stubbing the request
    visit "/index.html"
    sign_in
    click_tab(:save)

    # Mock a network error in JavaScript
    page.execute_script("
      window.fetch = function() {
        return Promise.reject(new Error('Network error'));
      };
    ")

    # Click save button
    save_button = page.find("[data-save-target='submitButton']")
    save_button.click

    # Verify error is displayed
    error_element = page.find("[data-save-target='error']", visible: :all)
    assert page.has_text?("Error: Network error")
  end

end