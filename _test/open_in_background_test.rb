require_relative "test_helper"

class OpenInBackgroundTest < SystemTest
  def test_open_in_background
    visit "/index.html"
    page.execute_script("window.mockCreatedTabs = [];")

    article_link = <<~EOT
      var link = document.createElement('a');
      link.id = 'source_link';
      link.href = 'https://kottke.org/24/01/example-article';
      document.body.appendChild(link);
    EOT

    page.execute_script(article_link)
    page.execute_script("browser.loadScript('assets/javascript/content/feedbin.js');")
    page.execute_script("browser.loadScript('assets/javascript/content/worker.js');")

    sleep 0.1

    page.execute_script("browser.mockTriggerCommand('open_in_background');")

    created_tabs = page.evaluate_script("window.mockCreatedTabs")
    assert_equal 1, created_tabs.length

    tab = created_tabs.first
    assert_equal "https://kottke.org/24/01/example-article", tab["url"]
    assert_equal false, tab["active"]
    assert_equal 1, tab["openerTabId"]
  end
end
