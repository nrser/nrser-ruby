module NRSER

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
  # @param [#each_pair, #each] enum
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
  # @raise [ArgumentError]
  #   If `enumerable` does not respond to `#each_pair` or `#each`.
  # 
  
  # Kind-of a Swiss Army knife for "I have the keys right, but I need to do
  # some work to get the values I want".
  # 
  # @overload map_values hash, &block
  #   
  #   Maps `hash` (which doesn't need to be a {Hash}, just support
  #   `#each_pair` in the same way) to a new {Hash} with the same keys and
  #   values created by calling `&block`.
  #   
  #   The arguments yielded to `&block` depend it's `#arity`:
  #   
  #   1.  If `&block` has more than one required argument
  #       (`block.arity > 1 || block.arity < -2`) then `key` and `value`
  #       will be yielded, so this works:
  #       
  #           NRSER.map_values( hash ) { |key, value| ... }
  #       
  #   2.  If `&block` has one required argument or less
  #       (`-2 <= block.arity <= 1`) then just `value` is yielded, so this
  #       also works:
  #       
  #           NRSER.map_values( hash ) { |value| ... }
  # 
  # @overload map_values enumerable, &block
  # 
  def self.map_values enum, &block
    result = {}
    
    arity = block.arity
    
    if enum.respond_to? :each_pair
      enum.each_pair { |key, value|
        result[key] = if arity > 1 ||  arity < -2
          block.call key, value
        else
          block.call value
        end
      }
    elsif enum.respond_to? :each
      value = nil
      enum.each_with_index { |key, index|
        result[key] = if arity > 1 || arity < -2
          block.call key, nil
        else
          block.call key
        end
      }
    else
      raise ArgumentError.new erb binding, <<-END
        First argument to {NRSER.map_values} must respond to #each_pair or #each
        
        Received
            
            <%= enum.pretty_inspect %>
        
        of class <%= enum.class %>
      END
    end
    
    result
  end # .map_values
  
end # module NRSER
