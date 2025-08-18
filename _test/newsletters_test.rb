require_relative "test_helper"

class NewslettersTest < SystemTest

  def test_addresses
    body = {
      token: "eovwr",
      addresses: [
        {
          email: "example.864@feedb.in",
          description: "Example Description"
        },
        {
          email: "jjtid@feedb.in",
          description: nil
        }
      ],
      tags: ["Favorites", "Newsletters"]
    }

    CapybaraMock.stub_request(:post, build_url("new_address"))
      .to_return(body: body.to_json)

    visit "/index.html"
    sign_in
    click_tab(:newsletters)

    within("[data-newsletters-target='addressList']") do
      body[:addresses].each do |address|
        assert_selector("[data-template='email']", text: address[:email])
        if address[:description]
          assert_selector("[data-template='description']", text: address[:description])
        end
      end
    end

    body[:addresses].each_with_index do |address, index|
      copy_button = find("[data-copy-data-value='#{address[:email]}']")

      if index == 0
        within(copy_button) do
          assert_selector("[data-copy-target='copyMessage']", text: "Copy")
        end
      end

      copy_button.click

      within(copy_button) do
        assert_selector("[data-copy-target='copyMessage']", text: "Copied")
      end

      assert_equal address[:email], copy_button["data-copy-data-value"]
    end

  end

  def test_auto_submit
    body = {
      token: "eovwr",
      email: "df.225@feedb.in",
      addresses: [],
      tags: []
    }

    CapybaraMock.stub_request(:post, build_url("new_address"))
      .to_return(body: body.to_json)

    body = {
      token: "custom.456",
      verified_token: "ImN1c3RvbS40NTYi--abc123",
      numbers: "456",
      email: "custom.456@feedb.in",
      addresses: [
        {
          email: "example.864@feedb.in",
          description: "Example Description"
        },
      ],
      tags: ["Favorites", "Newsletters"]
    }
    CapybaraMock.stub_request(:post, build_url("create_address"))
      .to_return(body: body.to_json)

    visit "/index.html"
    sign_in
    click_tab(:newsletters)

    assert_selector("[data-newsletters-target='addressInput']")

    input = find("[data-newsletters-target='addressInput']")
    assert_equal "eovwr", input.value

    assert_selector("[data-newsletters-target='addressOutput']", text: "df.225@feedb.in")

    input.set("custom")

    assert_selector("[data-newsletters-target='addressOutput']", text: "custom.456@feedb.in")
    assert_selector("[data-newsletters-target='numbers']", text: "456")

    assert_equal "true", find("[data-newsletters-edited-value]")["data-newsletters-edited-value"]

    assert_selector("[data-newsletters-target='submitButton']:disabled")
    assert_selector("[data-newsletters-target='submitButton']:not(:disabled)")
  end

  def test_created
    body = {
      token: "eovwr",
      email: "df.225@feedb.in",
      addresses: [],
      tags: []
    }

    CapybaraMock.stub_request(:post, build_url("new_address"))
      .to_return(body: body.to_json)

    create_body = {
      created: true,
      email: body[:email],
      addresses: []
    }
    CapybaraMock.stub_request(:post, build_url("create_address"))
      .to_return(body: create_body.to_json)

    visit "/index.html"
    sign_in
    click_tab(:newsletters)

    submit_button = find("[data-newsletters-target='submitButton']")
    submit_button.click

    assert_selector("[data-newsletters-target='copyButton']")
    copy_button = find("[data-newsletters-target='copyButton']")

    assert_equal create_body[:email], copy_button["data-copy-data-value"]
  end

  def test_invalid_address
    body = {
      token: "eovwr",
      email: "df.225@feedb.in",
      addresses: [],
      tags: []
    }

    CapybaraMock.stub_request(:post, build_url("new_address"))
      .to_return(body: body.to_json)

    body = {
      error: true
    }
    CapybaraMock.stub_request(:post, build_url("create_address"))
      .to_return(body: body.to_json, status: 400)

    visit "/index.html"
    sign_in
    click_tab(:newsletters)

    assert_selector("[data-newsletters-target='addressInput']")

    input = find("[data-newsletters-target='addressInput']")
    input.set("custom")

    assert page.has_text?("Invalid Address")
    refute page.has_text?("df.225@feedb.in")
  end
end
