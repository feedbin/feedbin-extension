require_relative "test_helper"

class AddTest < SystemTest

  def test_results
    body = {
      feeds: [
        {
          id: 31,
          feed_url: "https://daringfireball.net/feeds",
          title: "Daring Fireball",
          volume: "16h ago, 98/mo"
        },
        {
          id: 36,
          feed_url: "https://daringfireball.net/feeds.json",
          title: "Daring Fireball",
          volume: "16h ago, 98/mo"
        }
      ],
      tags: ["Favorites", "Feeds", "Social"]
    }

    CapybaraMock.stub_request(:post, build_url("find"))
      .to_return(body: body.to_json)

    visit "/index.html"
    sign_in
    click_tab(:add)

    # Verify feed results are displayed
    # assert_equal "2", page.find("[data-controller='subscribe']")["data-subscribe-results-count-value"]

    # Check that both feeds are displayed
    feed_inputs = page.all("input[data-template='feed_input']")
    assert_equal 2, feed_inputs.length
    assert_equal "Daring Fireball", feed_inputs[0].value
    assert_equal "Daring Fireball", feed_inputs[1].value

    # Check display URLs are shown
    display_urls = page.all("[data-template='display_url']")
    assert_equal 2, display_urls.length
    assert_equal "daringfireball.net › feeds", display_urls[0].text
    assert_equal "daringfireball.net › feeds.json", display_urls[1].text

    # Check volume information
    volumes = page.all("[data-template='volume']")
    assert_equal 2, volumes.length
    assert_equal "16h ago, 98/mo", volumes[0].text
    assert_equal "16h ago, 98/mo", volumes[1].text

    # Check that first feed is checked by default
    checkboxes = page.all("input[data-template='checkbox']")
    assert checkboxes[0].checked?
    refute checkboxes[1].checked?

    # Verify hidden URL inputs are set
    url_inputs = page.all("input[data-template='url']", visible: false)
    assert_equal 2, url_inputs.length
    assert_equal "https://daringfireball.net/feeds", url_inputs[0].value
    assert_equal "https://daringfireball.net/feeds.json", url_inputs[1].value

    # Check that tags are displayed
    tag_labels = page.all("[data-template='label']")
    assert_equal 3, tag_labels.length
    assert_equal "Favorites", tag_labels[0].text
    assert_equal "Feeds", tag_labels[1].text
    assert_equal "Social", tag_labels[2].text

    # Verify subscribe button is enabled (since first feed is checked by default)
    submit_button = page.find("[data-subscribe-target='submitButton']")
    refute submit_button.disabled?
  end

  def test_no_feeds_found_error
    body = {
      feeds: [],
      tags: []
    }

    CapybaraMock.stub_request(:post, build_url("find"))
      .to_return(body: body.to_json)

    visit "/index.html"
    sign_in
    click_tab(:add)

    # Verify error state is shown
    assert page.has_css?("[data-add-has-error-value=true]")
    assert page.has_text?("No feeds found")

    # Verify no results are shown
    refute page.has_css?("[data-add-has-results-value=true]")
  end

  def test_response_error
    CapybaraMock.stub_request(:post, build_url("find"))
      .to_return(status: 500, body: "Internal Server Error")

    visit "/index.html"
    sign_in
    click_tab(:add)

    # Verify error state is shown
    assert page.has_css?("[data-add-has-error-value=true]")
    assert page.has_text?("Invalid response: Internal Server Error")

    # Verify no results are shown
    refute page.has_css?("[data-add-has-results-value=true]")
  end
end
