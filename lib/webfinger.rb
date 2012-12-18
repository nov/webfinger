require "webfinger/version"

module WebFinger
  VERSION = File.read(
    File.join(File.dirname(__FILE__), '../VERSION')
  ).delete("\n\r")

  module_function

  def discover!(attributes = {})
    # TODO
  end

  def cache=(cache)
    @@cache = cache
  end
  def cache
    @@cache
  end

  def logger
    @@logger
  end
  def logger=(logger)
    @@logger = logger
  end
  logger = ::Logger.new(STDOUT)
  logger.progname = 'SWD'

  def debugging?
    @@debugging
  end
  def debugging=(boolean)
    @@debugging = boolean
  end
  def debug!
    debugging = true
  end
  debugging = false

  def http_client
    _http_client_ = HTTPClient.new(
      :agent_name => "WebFinger (#{VERSION})"
    )
    _http_client_.request_filter << Debugger::RequestFilter.new if debugging?
    http_config.try(:call, _http_client_)
    _http_client_
  end
  def http_config(&block)
    @@http_config ||= block
  end

  def url_builder
    @@url_builder ||= URI::HTTPS
  end
  def url_builder=(builder)
    @@url_builder = builder
  end
end
