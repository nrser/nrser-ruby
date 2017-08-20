module NRSER
  refine String do
    def squish
      NRSER.squish self
    end
    
    def unblock
      NRSER.unblock self
    end

    def dedent
      NRSER.dedent self
    end

    def indent *args
      NRSER.indent self, *args
    end

    def truncate *args
      NRSER.truncate self, *args
    end
    
    # See {NRSER.constantize}
    def constantize
      NRSER.constantize self
    end
    
    alias_method :to_const, :constantize
    
  end # refine String
end # NRSER
