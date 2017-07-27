module NRSER
  refine Object do
    def pipe
      yield self
    end
    
    def truthy?
      NRSER.truthy? self
    end
    
    def falsy?
      NRSER.falsy? self
    end
    
    # Calls {NRSER.as_hash} on `self` with the provided `key`.
    # 
    def as_hash key = nil
      NRSER.as_hash self, key
    end
    
    # Calls {NRSER.as_array} in `self`.
    def as_array
      NRSER.as_array self
    end
  end
end # NRSER