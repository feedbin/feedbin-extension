require "capybara"
require "capybara/dsl"
require "capybara/cuprite"
require "minitest/autorun"

Capybara.javascript_driver = :cuprite
Capybara.register_driver(:cuprite) do |app|
  Capybara::Selenium::Driver.new(app)
end

Capybara.run_server = true
Capybara.server = :webrick
Capybara.app = Rack::Builder.new do
  run Rack::Directory.new(File.expand_path("_site/extension"))
end

class SystemTest < Minitest::Test
  include Capybara::DSL

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end