
module NRSER
  
  # @!group Enumerable Functions
  
  # Test slice inclusion when both the `slice` and the `enum` that we're
  # going to look for it in support `#length` and `#slice`
  # in the same manner that {Array} does (hence the name).
  # 
  # This is much simpler and more efficient than the "general" {Enumerable}
  # case where we can't necessarily find out how many entries are in the
  # enumerables or really do much of anything with them except iterate through
  # (at least, with my current grasp of {Enumerable} and {Enumerator} it
  # seems painfully complex... in fact it may never terminate for infinite
  # enumerables).
  # 
  # @param [Enumerable<E> & #length & #slice] enum
  #   The {Enumerable} that we want test for `slice` inclusion. Must
  #   support `#length` and `#slice` like {Array} does.
  # 
  # @param [Enumerable<S> & #length & #slice] slice
  #   The {Enumerable} slice that we want to see if `enum` includes. Must
  #   support `#length` and `#slice` like {Array} does.
  # 
  # @param [Proc<(E, S)=>Boolean>] is_match
  #   Optional {Proc} that accepts an entry from `enum` and an entry from
  #   `slice` and returns if they match.
  # 
  # @return [Boolean]
  #   `true` if there is a slice of `enum` for which each entry matches the
  #   corresponding entry in `slice` according to `&is_match`.
  # 
  def self.array_include_slice? enum, slice, &is_match
    slice_length = slice.length
    
    # Short-circuit on empty slice - it's *always* present
    return true if slice_length == 0
    
    enum_length = enum.length
    
    # Short-circuit if slice is longer than enum since we can't possibly
    # match
    return false if slice_length > enum_length
    
    # Create a default `#==` matcher if we weren't provided one.
    if is_match.nil?
      is_match = ->(enum_entry, slice_entry) {
        enum_entry == slice_entry
      }
    end
    
    enum.each_with_index do |enum_entry, enum_start_index|
      # Compute index in `enum` that we would need to match up to
      enum_end_index = enum_start_index + slice_length - 1
      
      # Short-circuit if can't match (more slice entries than enum ones left)
      return false if enum_end_index >= enum_length
      
      # Create the slice to test against
      enum_slice = enum[enum_start_index..enum_end_index]
      
      # See if every entry in the slice from `enum` matches the corresponding
      # one in `slice`
      return true if enum_slice.zip( slice ).all? { |(enum_entry, slice_entry)|
        is_match.call enum_entry, slice_entry
      }
      
      # Otherwise, just continue on through `enum` looking for that first
      # match until the number of `enum` entries left is too few for `slice`
      # to possibly match
    end
    
    # We never matched the first `slice` entry to a `enum` entry (and `slice`
    # had to be of length 1 so that the "too long" short-circuit never fired).
    # 
    # So, we don't have a match.
    false
  end
  
  singleton_class.send :alias_method, :array_slice?, :array_include_slice?
  
end # module NRSER
