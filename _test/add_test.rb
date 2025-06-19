require_relative "test_helper"

class AddTest < SystemTest
  def test_site_info_presence
    visit "/index.html"

    sign_in

    # Navigate to add tab
    page.find(:css, "[value=tab-add]").trigger("click")

    assert page.has_css?("[data-page-info-has-data-value=true]")
    assert page.has_css?("[data-page-info-target=title]")
    assert page.has_css?("[data-page-info-target=description]")
    assert page.has_css?("[data-page-info-target=url]")

    title = page.find(:css, "[data-page-info-target=title]").text
    assert_equal "Title", title

    description = page.find(:css, "[data-page-info-target=description]").text
    assert_equal "Description", description
  end

  def test_site_info_error
    visit "/index.html"

    page.execute_script("window.mockNoTabsFound = true;")

    sign_in

    page.find(:css, "[value=tab-add]").trigger("click")

    assert page.has_css?("[data-page-info-has-error-value=true]")
    assert page.has_text?("Error loading extension")
  end
end
