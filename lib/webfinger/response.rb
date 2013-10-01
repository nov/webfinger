# NOTE:
#  Make a JSON Resource Descriptor (JRD) gem as separate one and use it as superclass?

module WebFinger
  class Response < ActiveSupport::HashWithIndifferentAccess
    def initialize(jrd)
      replace jrd
    end

    [:subject, :aliases, :properties, :links].each do |method|
      define_method method do
        self[method]
      end
    end

    def link_for(rel)
      links.detect do |link|
        link[:rel] == rel
      end
    end

    class << self
      # NOTE: Ugly hack to avoid this ActiveSupport 4.0 bug.
      #  https://github.com/rails/rails/issues/11087
      def new_from_hash_copying_default(hash)
        superclass.new_from_hash_copying_default hash
      end
    end
  end
end