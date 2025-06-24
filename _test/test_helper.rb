require "jekyll"
require "capybara"
require "capybara/dsl"
require "capybara/minitest"
require "capybara/cuprite"
require "capybara_mock"
require "minitest/autorun"
require "fileutils"

ENV["JEKYLL_ENV"] = "test"

PROJECT_ROOT = File.expand_path("..", __dir__)
SCREENSHOTS_DIR = File.join(PROJECT_ROOT, "tmp", "screenshots")

FileUtils.mkdir_p(SCREENSHOTS_DIR)
Dir.glob(File.join(SCREENSHOTS_DIR, "*.png")).each { |file| FileUtils.rm(file) }

$site = Jekyll::Site.new(Jekyll.configuration({
  source:  PROJECT_ROOT,
  destination: File.join(PROJECT_ROOT, "tmp", "_site"),
}))
$site.process

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app)
end

Capybara.configure do |config|
  config.javascript_driver = :cuprite
  config.default_driver = :cuprite
  config.default_max_wait_time = 1
  config.disable_animation = true
  config.server = :puma
  config.app = Rack::Builder.new do
    run Rack::Directory.new($site.dest)
  end
end

class SystemTest < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  def teardown
    if failure
      screenshot_path = File.join(SCREENSHOTS_DIR, "#{name}.png")
      page.save_screenshot(screenshot_path)
      failure.message << "\nScreenshot: #{screenshot_path}"
    end
    Capybara.reset_sessions!
    Capybara.use_default_driver
    CapybaraMock.reset!
  end
end

def build_url(path)
  URI.join($site.config["api_host"], $site.config["urls"][path]).to_s
end

def sign_in
  CapybaraMock.stub_request(:post, build_url("authentication"))
    .to_return(body: {page_token: "token"}.to_json)

  fill_in "Email", with: "example@example.com"
  fill_in "Password", with: "password"

  click_button("Sign In")
end

def click_tab(tab)
  page.find("[value=tab-#{tab}]").trigger("click")
end