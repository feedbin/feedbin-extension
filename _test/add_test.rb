require_relative "test_helper"

class AddTest < SystemTest

  def test_results
    stub_find(
      feed(id: 31, subscribed: false),
      feed(id: 36, feed_url: "https://daringfireball.net/feeds.json", subscribed: true),
      tags: ["Favorites", "Feeds", "Social"]
    )

    open_add_tab

    # Verify feed results are displayed
    # assert_equal "2", page.find("[data-controller='subscribe']")["data-subscribe-results-count-value"]

    # Check that both feeds are displayed
    feed_inputs = page.all("input[data-template='feed_input']")
    assert_equal 2, feed_inputs.length
    assert_equal "Daring Fireball", feed_inputs[0].value
    assert_equal "Daring Fireball", feed_inputs[1].value

    # Check display URLs are shown. The subscribed feed has nothing else to
    # report, so it falls back to its URL too.
    display_urls = page.all("[data-template='display_url']")
    assert_equal 2, display_urls.length
    assert_equal "daringfireball.net › feeds", display_urls[0].text
    assert_equal "daringfireball.net › feeds.json", display_urls[1].text

    # Check volume information. The subscribed feed shows Manage instead.
    volumes = page.all("[data-template='volume']")
    assert_equal 1, volumes.length
    assert_equal "16h ago, 98/mo", volumes[0].text

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

    assert checkboxes[1].disabled?, "Second checkbox should be disabled if `subscribed: true`"

    # Verify subscribe button is enabled (since first feed is checked by default)
    submit_button = page.find("[data-add-target='submitButton']")
    refute submit_button.disabled?
  end

  def test_subscribed_feed_shows_tags_and_manage_link
    stub_find(feed(id: 31, subscribed: true, tags: ["Design", "Tech"]))

    open_add_tab

    assert page.has_text?("✓ Already Subscribed")
    assert page.has_text?("Design, Tech")
    assert page.has_no_css?("[data-template='display_url']"), "Tags should replace the URL"
    assert page.has_no_css?("[data-template='volume']"), "Manage should replace the volume"

    manage = page.find("[data-template='manage']")
    assert_equal "Manage", manage.text
    assert_equal "https://example.com/settings/subscriptions/31/edit", manage["href"]
  end

  def test_subscribed_feed_without_tags_shows_url
    stub_find(feed(id: 31, subscribed: true))

    open_add_tab

    assert page.has_text?("daringfireball.net › feeds")
    assert page.has_css?("[data-template='manage']")
  end

  def test_muted_subscribed_feed
    stub_find(feed(id: 31, subscribed: true, muted: true, tags: ["Design"]))

    open_add_tab

    assert page.has_text?("Muted")
    assert page.has_no_text?("Design"), "Muted should replace the tags"
    assert page.has_css?("[data-template='manage']")
  end

  def test_subscribed_feed_with_crawl_error
    stub_find(feed(id: 31, subscribed: true, crawl_error: true, muted: true, tags: ["Design"]))

    open_add_tab

    assert page.has_text?("Error Crawling Feed")
    assert page.has_no_text?("Muted"), "A crawl error outranks mute"
    assert page.has_no_text?("Design"), "A crawl error outranks tags"
    assert page.has_css?("[data-template='manage']")
  end

  def test_no_feeds_found_error
    stub_find

    open_add_tab

    # Verify error state is shown
    assert page.has_css?("[data-add-state-value=error]")
    assert page.has_text?("No feeds found")
  end

  def test_response_error
    CapybaraMock.stub_request(:post, build_url("find"))
      .to_return(status: 500, body: "Internal Server Error")

    open_add_tab

    # Verify error state is shown
    assert page.has_css?("[data-add-state-value=error]")
    assert page.has_text?("Invalid response: Internal Server Error")
  end

  private

  def open_add_tab
    visit "/index.html"
    sign_in
    click_tab(:add)
  end

  def stub_find(*feeds, tags: [])
    CapybaraMock.stub_request(:post, build_url("find"))
      .to_return(body: {feeds: feeds, tags: tags}.to_json)
  end

  def feed(id:, subscribed:, feed_url: "https://daringfireball.net/feeds", muted: false, crawl_error: false, tags: [])
    {
      id: id,
      feed_url: feed_url,
      title: "Daring Fireball",
      volume: "16h ago, 98/mo",
      subscribed: subscribed,
      manage_url: subscribed ? "https://example.com/settings/subscriptions/#{id}/edit" : nil,
      muted: muted,
      crawl_error: crawl_error,
      tags: tags
    }
  end
end
