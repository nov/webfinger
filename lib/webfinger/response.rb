# NOTE:
#  Make a JSON Resource Descriptor (JRD) gem as separate one and use it as superclass?

module WebFinger
  class Response < Hash
    def initialize(jrd)
      replace jrd
    end

    [:subject, :aliases, :properties, :links].each do |method|
      define_method method do
        self[method]
      end
    end
  end
end