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
  end
end # NRSER