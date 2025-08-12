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
      token: "df.225",
      verified_token: "ImRmLjIyNSI=--d2ccbec34cce7ee9215bf331a55962bda726b912",
      numbers: "225",
      email: "df.225@feedb.in",
      addresses: [
        {
          email: "example.864@feedb.in",
          description: "Example Description"
        },
      ]
    }
    CapybaraMock.stub_request(:post, build_url("new_address"))
      .to_return(body: body.to_json)

    visit "/index.html"
    sign_in
    click_tab(:newsletters)

  end
end
