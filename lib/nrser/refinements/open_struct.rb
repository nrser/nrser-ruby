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
    
    
    # See {NRSER.to_open_struct}.
    def self.from_h hash
      NRSER.to_open_struct hash
    end # .from
    
  end
end # module NRSER
