module NRSER
  refine ::Array do
    # Create a `Hash` with the array's items as keys and results of calling
    # `&block` on each key as the value.
    # 
    # @yield [value]
    #   The array item (which will be the resulting hash key). Returned value
    #   is used as the key's value in the new `Hash`.
    # 
    # @return [Hash]
    # 
    def map_values &block
      result = {}
      self.each { |key| result[key] = block.call key }
      result
    end
    
    # Calls {NRSER.as_array} in `self`.
    def as_array
      NRSER.as_array self
    end
  end # Array
end # NRSER