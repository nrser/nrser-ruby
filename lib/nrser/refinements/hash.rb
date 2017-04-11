module NRSER
  refine Hash do
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
  end # Hash
end # NRSER