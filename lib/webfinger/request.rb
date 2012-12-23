module WebFinger
  class Request
    attr_accessor :resource, :relations

    def initialize(resource, options = {})
      self.resource = resource
      self.relations = Array(options[:rel] || options[:relations])
      @options = options
    end

    def discover!
      cached = WebFinger.cache.read cache_key
      if cached.blank? || cached.expired?
        fetched = handle_response do
          WebFinger.http_client.get_content endpoint.to_s
        end
        WebFinger.cache.write cache_key, fetched, expires_in: fetched.expires_in
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
      path = '/.well-known/webfinger'
      host, port = host_and_port
      WebFinger.url_builder.build [nil, host, port, path, query_string, nil]
    end

    def host_and_port
      uri = URI.parse(resource) rescue nil
      if uri.try(:host).present?
        [uri.host, [80, 443].include?(uri.port) ? nil : uri.port]
      else
        scheme_or_host, host_or_port, port_or_nil = resource.split('@').last.split('/').first.split(':')
        case host_or_port
        when nil, /\d+/
          [scheme_or_host, host_or_port.try(:to_i)]
        else
          [host_or_port, port_or_nil.try(:to_i)]
        end
      end
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