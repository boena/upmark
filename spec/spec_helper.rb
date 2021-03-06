require "parslet/rig/rspec"
require "rspec"
require "simplecov"

if ENV["BUILDBOX"]
  SimpleCov.start do
    add_filter "spec/"
    add_filter "vendor/bundle/"
  end
end

require "upmark"

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.order = :random

  config.example_status_persistence_file_path = '.examples'
end
