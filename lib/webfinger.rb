require 'json'
require 'faraday'
require 'faraday_middleware'
require 'active_support'
require 'active_support/core_ext'

module WebFinger
  VERSION = File.read(
    File.join(File.dirname(__FILE__), '../VERSION')
  ).delete("\n\r")

  module_function

  def discover!(resource, options = {})
    Request.new(resource, options).discover!
  end

  def logger
    @logger
  end
  def logger=(logger)
    @logger = logger
  end
  self.logger = ::Logger.new(STDOUT)
  logger.progname = 'WebFinger'

  def debugging?
    @debugging
  end
  def debugging=(boolean)
    @debugging = boolean
  end
  def debug!
    self.debugging = true
  end
  self.debugging = false

  def url_builder
    @url_builder ||= URI::HTTPS
  end
  def url_builder=(builder)
    @url_builder = builder
  end

  def http_client
    Faraday.new(headers: {user_agent: "WebFinger #{VERSION}"}) do |f|
      f.response :raise_error
      f.response :json
      f.response :logger, WebFinger.logger if debugging?
      f.use FaradayMiddleware::FollowRedirects
      http_config.try(:call, f)
    end
  end

  def http_config(&block)
    @http_config ||= block
  end
end

require 'webfinger/exception'
require 'webfinger/request'
require 'webfinger/response'
