require 'httpclient'

module WebFinger
  VERSION = File.read(
    File.join(File.dirname(__FILE__), '../VERSION')
  ).delete("\n\r")

  module_function

  def discover!(attributes = {})
    # TODO
  end

  def cache=(cache)
    @cache = cache
  end
  def cache
    @cache
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
    _http_client_ = HTTPClient.new(
      agent_name: "WebFinger (#{VERSION})"
    )
    _http_client_.request_filter << Debugger::RequestFilter.new if debugging?
    http_config && http_config.call(_http_client_)
    _http_client_
  end
  def http_config(&block)
    @http_config ||= block
  end
end

require 'webfinger/debugger'