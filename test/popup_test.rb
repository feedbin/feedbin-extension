require_relative 'test_helper'

class PopupTest < SystemTest
  def test_popup_loads
    visit '/popup.html'
    puts page.title
    assert page.title == 'Feedbin Subscribe & Save'
  end
end