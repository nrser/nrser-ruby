require_relative './include_slice/array_include_slice'


module NRSER
  
  # @!group Enumerable Functions
  
  # See if an `enum` includes a `slice`, using an optional block to do custom
  # matching.
  # 
  # @example Order matters
  #   NRSER.slice? [1, 2, 3], [2, 3]
  #   # => true
  #   
  #   NRSER.slice? [1, 2, 3], [3, 2]
  #   # => false
  # 
  # @example The empty slice is always present
  #   NRSER.slice? [1, 2, 3], []
  #   # => true
  #   
  #   NRSER.slice? [], []
  #   # => true
  # 
  # @example Custom `&is_match` block to prefix-match
  #   NRSER.slice?(
  #     ['neil', 'mica', 'hudie'],
  #     ['m', 'h']
  #   ) { |enum_entry, slice_entry|
  #     enum_entry.start_with? slice_entry
  #   }
  #   # => true
  # 
  # @note
  #   Right now, just forwards to {NRSER.array_include_slice?}, which requires
  #   that the {Enumerable}s support {Array}-like `#length` and `#slice`. I
  #   took a swing at the general case but it came out messy and only partially
  #   correct.
  # 
  # @param [Enumerable] enum
  #   Sequence to search in.
  # 
  # @param [Enumerable] slice
  #   Slice to search for.
  # 
  # @return [Boolean]
  #   `true` if `enum` has a slice matching `slice`.
  # 
  def self.include_slice? enum, slice, &is_match
    # Check that both args are {Enumerable}
    unless  Enumerable === enum &&
            Enumerable === slice
      raise TypeError.new binding.erb <<-END
        Both `enum` and `slice` must be {Enumerable}
        
        enum (<%= enum.class.safe_name %>):
        
            <%= enum.pretty_inspect %>
        
        slice (<%= slice.class.safe_name %>):
        
            <%= slice.pretty_inspect %>
        
      END
    end
    
    if [enum, slice].all? { |e|
      e.respond_to?( :length ) && e.respond_to?( :slice )
    }
      return array_include_slice? enum, slice, &is_match
    end
    
    raise NotImplementedError.new binding.erb <<-END
      Sorry, but general {Enumerable} slice include has not been implemented
      
      It's kinda complicated, or at least seems that way at first, so I'm
      going to punt for now...
    END
  end
  
  singleton_class.send :alias_method, :slice?, :include_slice?
  
end # module NRSER
