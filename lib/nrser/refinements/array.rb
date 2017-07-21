module NRSER
  refine ::Array do
    def map_values &block
      result = {}
      self.each { |key| result[key] = block.call key }
      result
    end
  end # Hash
end # NRSER