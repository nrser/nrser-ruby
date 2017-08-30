module NRSER
  
  # Eigenclass (Singleton Class)
  # ========================================================================
  # 
  class << self
    # Maps an enumerable object to a *new* hash with the same keys and values 
    # obtained by calling `block` with the current key and value.
    # 
    # If `enumerable` *does not* respond to `#to_pairs` then it's 
    # treated as a hash where the elements iterated by `#each` are it's keys
    # and all it's values are `nil`.
    # 
    # In this way, {NRSER.map_values} handles Hash, Array, Set, OpenStruct,
    # and probably pretty much anything else reasonable you may throw at it.
    # 
    # @param [#each_pair, #each] enumerable
    # 
    # @yieldparam [Object] key
    #   The key that will be used for whatever value the block returns in the
    #   new hash.
    # 
    # @yieldparam [nil, Object] value
    #   If `enumerable` responds to `#each_pair`, the second parameter it yielded
    #   along with `key`. Otherwise `nil`.
    # 
    # @yieldreturn [Object]
    #   Value for the new hash.
    # 
    # @return [Hash]
    # 
    # @raise [TypeError]
    #   If `enumerable` does not respond to `#each_pair` or `#each`.
    # 
    def map_values enumerable, &block
      result = {}
      
      if enumerable.respond_to? :each_pair
        enumerable.each_pair { |key, value|
          result[key] = block.call key, value
        }
      elsif enumerable.respond_to? :each
        enumerable.each { |key| 
          result[key] = block.call key, nil
        }
      else
        raise TypeError.new NRSER.squish <<-END
          First argument must respond to #each_pair or #each
          (found #{ enumerable.inspect })
        END
      end
      
      result
    end # #map_values
    
  end # class << self (Eigenclass)
end # module NRSER
