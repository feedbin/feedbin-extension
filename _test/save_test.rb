require_relative "test_helper"

class SaveTest < SystemTest
  def test_site_info_presence
    visit "/index.html"

    sign_in

    click_tab(:save)

    assert_equal "Title", page.find(:css, "[data-page-info-target=title]").text
    assert_equal "Description", page.find(:css, "[data-page-info-target=description]").text
    assert_equal "http://example.com", page.find(:css, "[data-page-info-target=url]").text
  end

  def test_site_info_error
    visit "/index.html"

    page.execute_script("window.mockNoTabsFound = true;")

    sign_in

    click_tab(:save)

    assert page.has_css?("[data-page-info-has-error-value=true]")
    assert page.has_text?("Error loading extension")
  end
end
