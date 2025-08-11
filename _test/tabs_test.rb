require_relative "test_helper"

class TabsTest < SystemTest
  def test_remember_tab
    visit "/index.html"

    sign_in

    # default after sign in is add
    assert tab_selected?(:add)

    click_tab(:save)

    visit "/index.html"

    # should be saved after click
    assert tab_selected?(:save)
  end
end