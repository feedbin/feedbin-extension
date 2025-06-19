require_relative "test_helper"

class AddTest < SystemTest
  def test_site_info_presence
    visit "/index.html"

    sign_in

    click_tab(:add)

    assert_equal "Site Name", page.find("[data-page-info-target=title]").text
    assert_equal "example.com", page.find("[data-page-info-target=url]").text
  end

  def test_site_info_error
    visit "/index.html"

    page.execute_script("window.mockNoTabsFound = true;")

    sign_in

    click_tab(:add)

    assert page.has_css?("[data-page-info-has-error-value=true]")
    assert page.has_text?("Error loading extension")
  end
end
