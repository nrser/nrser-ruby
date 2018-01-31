# Definitions
# =======================================================================

module NRSER
  refine Object do
    # Yield `self`. Analogous to {#tap} but returns the result of the invoked
    # block.
    def thru
      yield self
    end
    
    # Older name, depreciated because though 'pipe' was the natural name to me,
    # it was probably a poor choice... it's widely used and usually denotes
    # streaming of some sort (and rightfully so given Unix pipes).
    # 
    # I think I want to move over to {Object#thru}, but will leave the old
    # name for the moment.
    # 
    alias_method :pipe, :thru
    
    
    # See {NRSER.truthy?}.
    def truthy?
      NRSER.truthy? self
    end
    
    # See {NRSER.falsy?}.
    def falsy?
      NRSER.falsy? self
    end
    
    # Calls {NRSER.as_hash} on `self` with the provided `key`.
    def as_hash key = nil
      NRSER.as_hash self, key
    end
    
    # Call {NRSER.as_array} on `self`.
    def as_array
      NRSER.as_array self
    end
  end
end # NRSER
