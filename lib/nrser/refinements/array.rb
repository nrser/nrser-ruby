module NRSER
  refine ::Array do
    
    # See {NRSER.map_values}
    def map_values &block
      NRSER.map_values self, &block
    end
    
    
    # See {NRSER.find_bounded}
    def find_bounded bounds, &block
      NRSER.find_bounded self, bounds, &block
    end
    
    
    # See {NRSER.find_only}
    def find_only &block
      NRSER.find_only self, &block
    end
    
    
    # See {NRSER.to_h_by}
    def to_h_by &block
      NRSER.to_h_by self, &block
    end
    
  end # refine ::Array
end # NRSER