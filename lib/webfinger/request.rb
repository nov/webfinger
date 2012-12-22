module WebFinger
  class Request
    attr_accessor :resource, :relations

    def initialize(resource, options = {})
      self.resource = resource
      self.relations = Array(options[:rel] || options[:relations])
      @options = options
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
      uri = URI.parse(resource)
      path = '/.well-known/webfinger'
      host, port = if uri.host
        [uri.host, [80, 443].include?(uri.port) ? nil : uri.port]
      else
        resource.sub("#{uri.scheme}:", '').split('@').last.split('/').first.split(':')
      end
      WebFinger.url_builder.build [nil, host, port.try(:to_i), path, query_string, nil]
    end

    def query_string
      query_params.join('&')
    end

    def query_params
      query_params = [{resource: resource}]
      relations.each do |relation|
        query_params << {rel: relation}
      end
      query_params.collect(&:to_query)
    end

    def handle_response
      raw_response = yield
      jrd = MultiJson.load raw_response, symbolize_keys: true
      Response.new jrd
    rescue HTTPClient::BadResponseError => e
      case e.res.try(:status)
      when nil
        raise e
      when 400
        raise BadRequest.new('Bad Request', raw_response)
      when 401
        raise Unauthorized.new('Unauthorized', raw_response)
      when 403
        raise Forbidden.new('Forbidden', raw_response)
      when 404
        raise NotFound.new('Not Found', raw_response)
      else
        raise HttpError.new(e.res.status, e.res.reason, raw_response)
      end
    end
  end
end