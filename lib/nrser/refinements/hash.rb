module NRSER
  refine ::Hash do
    # lifted from ActiveSupport
    def except! *keys
      keys.each { |key| delete(key) }
      self
    end
    
    alias_method :omit!, :except!
    
    # lifted from ActiveSupport
    def except *keys
      dup.except! *keys
    end
    
    alias_method :omit, :except
    
    # See {NRSER.leaves}.
    def leaves
      NRSER.leaves self
    end # #leaves
    
    # See {NRSER.map_hash_values}.
    def map_values &block
      NRSER.map_hash_values self, &block
    end
  end # Hash
end # NRSER