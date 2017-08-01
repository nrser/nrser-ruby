module NRSER
  refine ::Array do
    # See {NRSER.map_array_values}
    def map_values &block
      NRSER.map_values self, &block
    end
  end # Array
end # NRSER