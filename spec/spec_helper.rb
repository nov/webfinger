require 'simplecov'

SimpleCov.start do
  add_filter 'spec'
end

require 'rspec'
require 'webfinger'
require 'helpers/webmock_helper'