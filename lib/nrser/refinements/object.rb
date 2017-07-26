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
    def as_hash key
      NRSER.as_hash self, key
    end
  end
end # NRSER