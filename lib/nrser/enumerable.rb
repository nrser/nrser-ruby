module NRSER
  # Maps an enumerable object to a *new* hash with the same keys and values 
  # obtained by calling `block` with the current key and value.
  # 
  # If `enumerable` *does not* sucessfully respond to `#to_h` then it's 
  # treated as a hash where it's elements are the keys and all the values
  # are `nil`.
  # 
  # @return [Hash]
  # 
  def self.map_values enumerable, &block
    # Short-cut for Hash itself - though it would of course work through the
    # next step, it's going to probably be *the* most common argument type,
    # and there's no reason to do the tests and set up the exception 
    # handler if we already know what's up with it.
    return NRSER.map_hash_values(enumerable, &block) if enumerable.is_a? Hash
    
    if enumerable.respond_to? :to_h
      begin
        hash = enumerable.to_h
      rescue TypeError => e
      else
        return NRSER.map_hash_values hash, &block
      end
    end
    
    result = {}
    enumerable.each { |key| result[key] = block.call key, nil }
    result
  end
end # module NRSER
