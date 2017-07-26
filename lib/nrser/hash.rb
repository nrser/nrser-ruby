module NRSER
  
  
  def self.leaves hash, path: [], results: {}
    hash.each { |key, value|
      new_path = [*path, key]
      
      case value
      when Hash
        leaves value, path: new_path, results: results
      else
        results[new_path] = value
      end
    }
    
    results
  end # .leaves
  
  
  # Treat the value as the value for `key` in a hash if it's not already a
  # hash and can't be converted to one:
  # 
  # 1.  If the value is a {Hash}, return it.
  # 2.  If the value responds to `#to_h` and `#to_h` succeeds, return the
  #     resulting hash.
  # 3.  Otherwise, return a new hash where `key` points to the value.
  # 
  # Useful in method overloading and similar situations where you expect a 
  # hash that may specify a host of options, but want to allow the method
  # to be called with a single value that corresponds to a default key in that
  # option hash.
  # 
  # @example
  #   Say you have a 
  # 
  def self.as_hash value, key
    return value if value.is_a? Hash
    
    if value.respond_to? :to_h
      begin
        return value.to_h
      rescue
      end
    end
    
    {key => value}
  end # .as_hash
  
  
end # module NRSER