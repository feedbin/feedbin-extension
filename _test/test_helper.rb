require "jekyll"
require "capybara"
require "capybara/dsl"
require "capybara/minitest"
require "capybara/cuprite"
require "capybara_mock"
require "minitest/autorun"
require "fileutils"

ENV["JEKYLL_ENV"] = "test"

SCREENSHOTS = File.join("tmp", "screenshots")

SITE = Jekyll::Site.new(Jekyll.configuration({
  source: "./",
  destination: File.join("tmp", "_site"),
}))
SITE.process

FileUtils.mkdir_p(SCREENSHOTS)
Dir.glob(File.join(SCREENSHOTS, "*.png")).each { |file| FileUtils.rm(file) }

Capybara.register_driver(:cuprite) do
  Capybara::Cuprite::Driver.new(it)
end

Capybara.configure do
  it.javascript_driver = :cuprite
  it.default_driver = :cuprite
  it.default_max_wait_time = 1
  it.disable_animation = true
  it.server = :puma
  it.app = Rack::Builder.new do
    run Rack::Directory.new(SITE.dest)
  end
end

class SystemTest < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  def teardown
    capture_screenshot_on_failure
    reset_test_state
  end

  private

  def capture_screenshot_on_failure
    return unless failure

    screenshot_path = File.join(SCREENSHOTS, "#{name}.png")
    page.save_screenshot(screenshot_path)
    failure.message << "\nScreenshot: #{screenshot_path}"
  end

  def reset_test_state
    Capybara.reset_sessions!
    Capybara.use_default_driver
    CapybaraMock.reset!
  end
end

def build_url(path)
  URI.join(SITE.config["api_host"], SITE.config["urls"][path]).to_s
end

def sign_in
  CapybaraMock.stub_request(:post, build_url("authentication"))
    .to_return(body: { page_token: "token" }.to_json)

  fill_in "Email", with: "example@example.com"
  fill_in "Password", with: "password"

  click_button("Sign In")
end

def click_tab(tab)
  page.find("[value=tab-#{tab}]").trigger("click")
end

def tab_selected?(tab)
  page.find("[name=tab]:checked").value() == "tab-#{tab}"
end