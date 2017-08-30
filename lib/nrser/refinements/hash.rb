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
    
    
    # See {NRSER.map_values}.
    def map_values &block
      NRSER.map_values self, &block
    end
    
    # See {NRSER.transform_keys!}
    def transform_keys! &block
      return enum_for(:transform_keys!) { size } unless block_given?
      NRSER.transform_keys! self, &block
    end
    
    
    # See {NRSER.transform_keys}
    def transform_keys &block
      return hash.enum_for(:transform_keys) { size } unless block_given?
      NRSER.transform_keys self, &block
    end
    
    
    # See {NRSER.symbolize_keys!}
    def symbolize_keys!
      NRSER.symbolize_keys! self
    end
    
    
    # See {NRSER.symbolize_keys}
    def symbolize_keys
      NRSER.symbolize_keys self
    end
    
    
    # See {NRSER.stringify_keys!}
    def stringify_keys!
      NRSER.stringify_keys! self
    end
    
    
    # See {NRSER.stringify_keys}
    def stringify_keys
      NRSER.stringify_keys self
    end
    
    # See {NRSER.map_hash_keys}
    def map_keys &block
      NRSER.map_keys self, &block
    end
  end # Hash
end # NRSER