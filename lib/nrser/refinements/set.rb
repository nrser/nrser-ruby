require 'set'

module NRSER
  refine ::Set do
    
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
    
  end # refine ::Set
end # NRSER