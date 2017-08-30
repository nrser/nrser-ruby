module NRSER
  refine ::Set do
    # See {NRSER.map_values}
    def map_values &block
      NRSER.map_values self, &block
    end
  end # ::Set
end # NRSER