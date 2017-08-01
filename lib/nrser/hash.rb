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
  # 1.  If the value is a `Hash`, return it.
  #     
  # 2.  If `value` is `nil`, return `{}`.
  #     
  # 3.  If the value responds to `#to_h` and `#to_h` succeeds, return the
  #     resulting hash.
  #     
  # 4.  Otherwise, return a new hash where `key` points to the value.
  #     **`key` MUST be provided in this case.**
  # 
  # Useful in method overloading and similar situations where you expect a 
  # hash that may specify a host of options, but want to allow the method
  # to be called with a single value that corresponds to a default key in that
  # option hash.
  # 
  # Refinement
  # ----------
  # 
  # Added to `Object` in `nrser/refinements`.
  # 
  # 
  # Example Time!
  # -------------
  # 
  # Say you have a method `m` that handles a hash of HTML options that can
  # look something like
  # 
  #     {class: 'address', data: {confirm: 'Really?'}}
  # 
  # And can call `m` like
  # 
  #     m({class: 'address', data: {confirm: 'Really?'}})
  # 
  # but often you are just dealing with the `:class` option. You can use
  # {NRSER.as_hash} to accept a string and treat it as the `:class` key:
  # 
  #     using NRSER
  #     
  #     def m opts
  #       opts = opts.as_hash :class
  #       # ...
  #     end
  # 
  # If you pass a hash, everything works normally, but if you pass a string
  # `'address'` it will be converted to `{class: 'address'}`.
  # 
  # 
  # About `#to_h` Support
  # ---------------------
  # 
  # Right now, {.as_hash} also tests if `value` responds to `#to_h`, and will
  # try to call it, using the result if it doesn't raise. This lets it deal 
  # with Ruby's "I used to be a Hash until someone mapped me" values like
  # `[[:class, 'address']]`. I'm not sure if this is the best approach, but 
  # I'm going to try it for now and see how it pans out in actual usage.
  # 
  # @todo
  #   It might be nice to have a `check` option that ensures the resulting
  #   hash has a value for `key`.
  # 
  # @param [Object] value
  #   The value that we want to be a hash.
  # 
  # @param [Object] key [default nil]
  #   The key that `value` will be stored under in the result if `value` is 
  #   not a hash or can't be turned into one via `#to_h`. If this happens
  #   this value can **NOT** be `nil` or an `ArgumentError` is raised.
  # 
  # @return [Hash]
  # 
  # @raise [ArgumentError]
  #   If it comes to constructing a new Hash with `value` as a value and no
  #   argument was provided 
  # 
  def self.as_hash value, key = nil
    return value if value.is_a? Hash
    return {} if value.nil?
    
    if value.respond_to? :to_h
      begin
        return value.to_h
      rescue
      end
    end
    
    # at this point we need a key argument
    if key.nil?
      raise ArgumentError,
            "Need key to construct hash with value #{ value.inspect }, " +
            "found nil."
    end
    
    {key => value}
  end # .as_hash
  
  
  
  # @todo Document map_hash_values method.
  # 
  # @param [Hash] hash
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.map_hash_values hash, &block
    result = {}
    hash.each { |key, value| result[key] = block.call key, value }
    result
  end # #map_hash_values
  
end # module NRSER