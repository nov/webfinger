module WebFinger
  class Request
    attr_accessor :resource, :relations, :path

    def initialize(resource, options = {})
      self.resource = resource
      self.relations = Array(options[:rel] || options[:relations])
      self.path ||= '/.well-known/webfinger'
    end

    def discover!(cache_options = nil)
      cached = WebFinger.cache.read cache_key
      if cached.blank? || cached.expired?
        fetched = handle_response do
          WebFinger.http_client.get_content endpoint.to_s
        end
        cache_options ||= {}
        cache_options[:expires_in] ||= fetched.expires_in
        WebFinger.cache.write cache_key, fetched, cache_options
        fetched
      else
        cached
      end
    end

    private

    def cache_key
      "webfinger:resource:#{Digest::MD5.hexdigest query_string}"
    end

    def endpoint
      host = URI.parse(resource).host || resource.split(':').last.split('@').last
      WebFinger.url_builder.build [nil, host, nil, path, query_string, nil]
    rescue URI::Error => e
      raise Exception.new(e.message)
    end

    def query_string
      query_params.join('&')
    end

    def query_params
      _query_params_ = [{resource: resource}.to_query]
      relations.each do |relation|
        _query_params_ << {rel: relation}.to_query
      end
      _query_params_
    end

    def handle_response
      raw_jrd = yield
      jrd = MultiJson.load raw_jrd, symbolize_keys: true
      Response.new jrd
    rescue HTTPClient::BadResponseError => e
      case e.res.try(:status)
      when nil
        raise Exception.new(e.message)
      when 400
        raise BadRequest.new('Bad Request', res)
      when 401
        raise Unauthorized.new('Unauthorized', res)
      when 403
        raise Forbidden.new('Forbidden', res)
      when 404
        raise NotFound.new('Not Found', res)
      else
        raise HttpError.new(e.res.status, e.res.reason, res)
      end
    end
  end
end