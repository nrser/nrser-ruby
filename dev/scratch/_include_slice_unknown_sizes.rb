
module NRSER
  
  # @!group Enumerable Functions
  
  # A "general" slice inclusion test that can be used with {Enumerable}s that
  # basically have nothing known about their .
  # 
  # The code is horrible complex and tedious, mostly due to having to rescue
  # {StopIteration} exceptions to figure out that {Enumerator} instances are
  # out of entires, *but*, I *think* it works.
  # 
  # @private
  # 
  def self._include_slice__enumerators? enum, slice, &is_match
    logger = SemanticLogger['NRSER._include_slice__enumerators?']
    
    enum_iter = enum.each
    slice_iter = enum.each
    
    # Grab the first entry from `slice`, short-circuiting with `true` if there
    # isn't one (meaning `slice` is empty so it's a slice of `enum` by default)
    slice_first = begin
      slice_iter.next
    rescue StopIteration
      logger.debug "Slice has no entries => always in enum, returning TRUE"
      return true
    end
    
    # Create a default `#==` matcher if one was not provided
    if is_match.nil?
      is_match = ->(enum_entry, slice_entry) {
        enum_entry == slice_entry
      }
    end
    
    # Find entries in `enum` that match the first `slice` entry
    loop do
      begin
        # break if is_match.call( enum_iter.next, slice.first )
        
        enum_entry = enum_iter.next
        
        if is_match.call( enum_entry, slice_first )
          logger.debug "Found start",
            enum_entry: enum_entry,
            slice_entry: slice.first
          break
        else
          logger.debug "NOT start",
            enum_entry: enum_entry,
            slice_entry: slice.first
        end
      rescue StopIteration => error
        logger.debug "Run out of entries before finding first, returning FALSE",
          error: error
        return false
      end
    end
    
    loop do
      # return false unless is_match.call( enum_iter.next, slice_iter.next )
      enum_entry = begin
        enum_iter.next
      rescue StopIteration => enum_stop
        logger.debug "Enum is out!",
          enum_stop: enum_stop
        
        # The enum ran out... if the slice is out too then we're OK,
        # otherwise we're not
        begin
          slice_entry = slice_iter.next
        rescue StopIteration => slice_stop
          # Ok, both out at same time, it's a match still
          logger.debug "Slice is out too, return TRUE",
            slice_stop: slice_stop
          return true
        else
          logger.debug "There is still slice left, no match, return FALSE"
          return false
        end
      end
      
      slice_entry = begin
        slice_iter.next
      rescue StopIteration => slice_stop
        logger.debug "Slice is out w/o failing a match, return TRUE",
          slice_stop: slice_stop
        return true
      end
      
      if is_match.call( enum_entry, slice_entry )
        logger.debug "Enum and slice match",
          enum_entry: enum_entry,
          slice_entry: slice_entry
      else
        logger.debug "Enum and slice DON'T match, returning FALSE",
          enum_entry: enum_entry,
          slice_entry: slice_entry
        return false
      end
    end
  end
  
  private_class_method :_include_slice__enumerators?
  
end # module NRSER
