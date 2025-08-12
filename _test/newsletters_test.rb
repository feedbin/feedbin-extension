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
    }
    CapybaraMock.stub_request(:post, build_url("create_address"))
      .to_return(body: body.to_json)

    visit "/index.html"
    sign_in
    click_tab(:newsletters)

    # Wait for initial data to load
    assert_selector("[data-newsletters-target='addressInput']")

    input = find("[data-newsletters-target='addressInput']")
    assert_equal "eovwr", input.value

    assert_selector("[data-newsletters-target='addressOutput']", text: "df.225@feedb.in")

    input.set("custom")

    assert_selector("[data-newsletters-target='addressOutput']", text: "custom.456@feedb.in")
    assert_selector("[data-newsletters-target='numbers']", text: "456")

    assert_equal "true", find("[data-newsletters-edited-value]").value

    # Verify submit button was temporarily disabled and should re-enable after 500ms
    submit_button = find("[data-newsletters-target='submitButton']")
    # Button is disabled during auto-submit
    assert submit_button.disabled?

    # Wait for button to re-enable after timeout (500ms in the controller)
    sleep 0.6
    assert !submit_button.disabled?
  end
end
