module NRSER
  refine ::Hash do
    # See {NRSER.except_keys!}.
    def except! *keys
      NRSER.except_keys! self, *keys
    end
    
    alias_method :omit!, :except!
    
    
    # See {NRSER.except_keys}.
    def except *keys
      NRSER.except_keys self, *keys
    end
    
    alias_method :omit, :except
    
    
    # See {NRSER.slice_keys}.
    def slice *keys
      NRSER.slice_keys self, *keys
    end
    
    
    # See {NRSER.leaves}.
    def leaves
      NRSER.leaves self
    end # #leaves
    
    
    # See {NRSER.map_hash_values}.
    def map_values &block
      NRSER.map_hash_values self, &block
    end
    
    
    def transform_keys! &block
      return enum_for(:transform_keys!) { size } unless block_given?
      NRSER.transform_keys! self, &block
    end
    
    
    def transform_keys &block
      return hash.enum_for(:transform_keys) { size } unless block_given?
      NRSER.transform_keys self, &block
    end
    
    
    def symbolize_keys!
      NRSER.symbolize_keys! self
    end
    
    
    def symbolize_keys
      NRSER.symbolize_keys self
    end
    
    
    def map_keys &block
      NRSER.map_hash_keys self, &block
    end
  end # Hash
end # NRSER