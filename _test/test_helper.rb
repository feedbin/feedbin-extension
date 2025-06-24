require "jekyll"
require "capybara"
require "capybara/dsl"
require "capybara/minitest"
require "capybara/cuprite"
require "capybara_mock"
require "minitest/autorun"
require "fileutils"

ENV["JEKYLL_ENV"] = "test"

# Clean screenshots directory before running tests
screenshots_dir = File.join("tmp", "screenshots")
FileUtils.mkdir_p(screenshots_dir)
Dir.glob(File.join(screenshots_dir, "*.png")).each { |file| FileUtils.rm(file) }

$site = Jekyll::Site.new(Jekyll.configuration({
  source:  Dir.pwd,
  destination: File.join(Dir.pwd, "tmp", "_site"),
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
      path = File.join("tmp", "screenshots", "#{name}.png")
      page.save_screenshot(path)
      failure.message << "\nScreenshot: #{path}"
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