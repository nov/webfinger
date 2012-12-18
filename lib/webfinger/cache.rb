module WebFinger
  class Cache
    def read(cache_key)
      nil
    end

    def write(cache_key, object, options = {})
      # do nothing
      true
    end
  end
end