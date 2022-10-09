module WebFinger
  class Request
    attr_accessor :resource, :relations

    def initialize(resource, options = {})
      self.resource = resource
      self.relations = Array(options[:rel] || options[:relations])
      @options = options
    end

    def discover!
      handle_response do
        WebFinger.http_client.get(endpoint.to_s)
      end
    end

    private

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
      json = yield.body.with_indifferent_access
      Response.new json
    rescue Faraday::Error => e
      case e.response_status
      when nil
        raise Exception.new e
      when 400
        raise BadRequest.new('Bad Request', e.response_body)
      when 401
        raise Unauthorized.new('Unauthorized', e.response_body)
      when 403
        raise Forbidden.new('Forbidden', e.response_body)
      when 404
        raise NotFound.new('Not Found', e.response_body)
      else
        raise HttpError.new(e.response_status, e.response_body, e.response_body)
      end
    end
  end
end
