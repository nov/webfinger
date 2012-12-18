# NOTE:
#  Make a JSON Resource Descriptor (JRD) gem as separate one and use it as superclass?

module WebFinger
  class Response < Hash
    def initialize(hash)
      replace hash
    end

    [:subject, :aliases, :properties, :links].each do |method|
      define_method method do
        self[method]
      end
    end

    def expired?
      expires.try(:past?)
    end
    def expires
      @expires ||= case self[:expires]
      when Time
        self[:expires]
      when String
        Time.parse self[:expires]
      end
    end
    def expires_in
      if expires.present?
        (expires - Time.now).to_i
      end
    end
  end
end