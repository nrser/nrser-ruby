require 'ostruct'

module NRSER 
  refine OpenStruct do
    
    # Map values using {NRSER.map_values} into a new {OpenStruct} instance.
    # 
    # @return [OpenStruct]
    # 
    def map_values &block
      self.class.new NRSER.map_values(self, &block)
    end # #map_values
    
  end
  
  refine OpenStruct.singleton_class do
    
    # See {NRSER.to_open_struct}.
    def from_h hash, freeze: false
      NRSER.to_open_struct hash, freeze: freeze
    end # .from
    
  end
end # module NRSER
