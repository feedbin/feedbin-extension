require "capybara"
require "capybara/dsl"
require "capybara/minitest"
require "capybara/cuprite"
require "capybara_mock"
require "minitest/autorun"

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app)
end

Capybara.configure do |config|
  config.javascript_driver = :cuprite
  config.default_driver = :cuprite
  config.default_max_wait_time = 5
  config.disable_animation = true
  config.server = :puma
  config.app = Rack::Builder.new do
    run Rack::Directory.new(File.expand_path("_site/extension"))
  end
end


class SystemTest < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end