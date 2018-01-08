module NRSER
  
  # @!group Enumerable Functions
  
  # Test if an object is "array-like" - is it an Enumerable and does it respond
  # to `#each_index`?
  # 
  # @param [Object] object
  #   Any old thing.
  # 
  # @return [Boolean]
  #   `true` if `object` is "array-like" for our purposes.
  # 
  def self.array_like? object
    object.is_a?( ::Enumerable ) &&
      object.respond_to?( :each_index )
  end # .array_like?
  
  
  # Test if an object is "hash-like" - is it an Enumerable and does it respond
  # to `#each_pair`?
  # 
  # @param [Object] object
  #   Any old thing.
  # 
  # @return [Boolean]
  #   `true` if `object` is "hash-like" for our purposes.
  # 
  def self.hash_like? object
    object.is_a?( ::Enumerable ) &&
      object.respond_to?( :each_pair )
  end # .hash_like?
  

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
  # @raise [TypeError]
  #   If `enumerable` does not respond to `#each_pair` or `#each`.
  # 
  def self.map_values enum, &block
    result = {}
    
    if enum.respond_to? :each_pair
      enum.each_pair { |key, value|
        result[key] = block.call key, value
      }
    elsif enum.respond_to? :each
      enum.each { |key|
        result[key] = block.call key, nil
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
  
  
  # Find all entries in an {Enumerable} for which `&block` returns a truthy
  # value, then check the amount of results found against the
  # {NRSER::Types.length} created from `bounds`, raising a {TypeError} if
  # the results' length doesn't satisfy the bounds type.
  # 
  # @param [Enumerable<E>] enum
  #   The entries to search and check.
  # 
  # @param [Integer | Hash] bounds
  #   Passed as only argument to {NRSER::Types.length} to create the length
  #   type the results are checked against.
  # 
  # @param [Proc] &block
  #   `#find`/`#find_all`-style block that will be called with each entry
  #   from `enum`. Truthy responses mean the entry matched.
  # 
  # @return [Array<E>]
  #   Found entries from `enum`.
  # 
  # @raise [TypeError]
  #   If the results of `enum.find_all &block` don't satisfy `bounds`.
  # 
  def self.find_bounded enum, bounds, &block
    NRSER::Types.
      length(bounds).
      check(enum.find_all &block) { |type:, value:|
        erb binding, <<-END
          
          Length of found elements (<%= value.length %>) FAILED to
          satisfy <%= type.to_s %>.
          
          Found entries:
          
              <%= value.pretty_inspect %>
          
          from enumerable:
          
              <%= enum.pretty_inspect %>
          
        END
      }
  end # .find_bounded
  
  
  # Find the only entry in `enum` for which `&block` responds truthy, raising
  # if either no entries or more than one are found.
  # 
  # Returns the entry itself, not an array of length 1.
  # 
  # Just calls {NRSER.find_bounded} with `bounds = 1`.
  # 
  # @param enum (see NRSER.find_bounded)
  # @param &block (see NRSER.find_bounded)
  # 
  # @return [E]
  #   Only entry in `enum` that `&block` matched.
  # 
  # @raise [TypeError]
  #   If `&block` matched more or less than one entry.
  # 
  def self.find_only enum, &block
    find_bounded(enum, 1, &block).first
  end # .find_only
  
  
  # Return the first entry if the enumerable has `#count` one.
  # 
  # Otherwise, return `default` (which defaults to `nil`).
  # 
  # @param [Enumerable<E>] enum
  #   Enumerable in question (really, anything that responds to `#first` and
  #   `#count`).
  # 
  # @param [D] default:
  #   Value to return if `enum` does not have only one entry.
  # 
  # @return [E]
  #   When `enum` has `#count == 1`.
  # 
  # @return [D]
  #   When `enum` does not have `#count == 1`.
  # 
  def self.only enum, default: nil
    if enum.count == 1
      enum.first
    else
      default
    end
  end # .only
  
  
  # Return the only entry if the enumerable has `#count` one. Otherwise
  # raise an error.
  # 
  # @param enum (see NRSER.only)
  # 
  # @return [E]
  #   First element of `enum`.
  # 
  # @raise [ArgumentError]
  #   If `enum` does not have `#count == 1`.
  # 
  def self.only! enum
    unless enum.count == 1
      raise ArgumentError.new erb binding, <<-END
        Expected enumerable to have #count == 1 but it has
        
        #count = <%= enum.count %>
        
        Enumerable (class: <%= enum.class %>):
        
            <%= enum.pretty_inspect %>
        
      END
    end
    
    enum.first
  end # .only!
  
  
  # Convert an enumerable to a hash by passing each entry through `&block` to
  # get it's key, raising an error if multiple entries map to the same key.
  # 
  # @param [Enumerable<V>] enum
  #   Enumerable containing the values for the hash.
  # 
  # @param [Proc<(V)=>K>] &block
  #   Block that maps `enum` values to their hash keys.
  # 
  # @return [Hash<K, V>]
  # 
  # @raise [NRSER::ConflictError]
  #   If two values map to the same key.
  # 
  def self.to_h_by enum, &block
    enum.each_with_object( {} ) { |element, result|
      key = block.call element
      
      if result.key? key
        raise NRSER::ConflictError.new erb binding, <<-END
          Key <%= key.inspect %> is already in results with value:
          
              <%= result[key].pretty_inspect %>
          
        END
      end
      
      result[key] = element
    }
  end # .to_h_by
  
  
  # Create an {Enumerator} that iterates over the "values" of an
  # {Enumerable} `enum`. If `enum` responds to `#each_value` than we return
  # that. Otherwise, we return `#each_entry`.
  # 
  # @param [Enumerable] enum
  # 
  # @return [Enumerator]
  # 
  # @raise [ArgumentError]
  #   If `enum` doesn't respond to `#each_value` or `#each_entry`.
  # 
  def self.enumerate_as_values enum
    # NRSER.match enum,
    #   t.respond_to(:each_value), :each_value.to_proc,
    #   t.respond_to(:each_entry), :each_entry.to_proc
    # 
    if enum.respond_to? :each_value
      enum.each_value
    elsif enum.respond_to? :each_entry
      enum.each_entry
    else
      raise ArgumentError.new erb binding, <<-END
        Expected `enum` arg to respond to :each_value or :each_entry, found:
        
            <%= enum.inspect %>
        
      END
    end
  end # .enumerate_as_values
  
  
  # Count entries in an {Enumerable} by the value returned when they are
  # passed to the block.
  # 
  # @example Count array entries by class
  #   
  #   [1, 2, :three, 'four', 5, :six].count_by &:class
  #   # => {Fixnum=>3, Symbol=>2, String=>1}
  # 
  # @param [Enumerable<E>] enum
  #   {Enumerable} (or other object with compatible `#each_with_object` and
  #   `#to_enum` methods) you want to count.
  # 
  # @param [Proc<(E)=>C>] &block
  #   Block mapping entries in `enum` to the group to count them in.
  # 
  # @return [Hash{C=>Integer}]
  #   Hash mapping groups to positive integer counts.
  # 
  def self.count_by enum, &block
    enum.each_with_object( Hash.new 0 ) do |entry, hash|
      hash[block.call entry] += 1
    end
  end # .count_by
  
  
  # Like `Enumerable#find`, but wraps each call to `&block` in a
  # `begin` / `rescue`, returning the result of the first call that doesn't
  # raise an error.
  # 
  # If no calls succeed, raises a {NRSER::MultipleErrors} containing the
  # errors from the block calls.
  # 
  # @param [Enumerable<E>] enum
  #   Values to call `&block` with.
  # 
  # @param [Proc<E=>V>] &block
  #   Block to call, which is expected to raise an error if it fails.
  # 
  # @return [V]
  #   Result of first call to `&block` that doesn't raise.
  # 
  # @raise [ArgumentError]
  #   If `enum` was empty (`enum#each` never yielded).
  # 
  # @raise [NRSER::MultipleErrors]
  #   If all calls to `&block` failed.
  # 
  def self.try_find enum, &block
    errors = []
    
    enum.each do |*args|
      begin
        result = block.call *args
      rescue Exception => error
        errors << error
      else
        return result
      end
    end
    
    if errors.empty?
      raise ArgumentError,
        "Appears that enumerable was empty: #{ enum.inspect }"
    else
      raise NRSER::MultipleErrors.new errors
    end
  end # .try_find
  
  
  # TODO It would be nice for this to work...
  # 
  # def to_enum object, meth, *args
  #   unless object.respond_to?( meth )
  #     object = NRSER::Enumerable.new object
  #   end
  # 
  #   object.to_enum meth, *args
  # end
  
end # module NRSER
