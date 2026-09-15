require 'simplecov'

SimpleCov.start do
  skip 'spec'
end

require 'rspec'
require 'rspec/its'
require 'webfinger'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

require 'helpers/webmock_helper'