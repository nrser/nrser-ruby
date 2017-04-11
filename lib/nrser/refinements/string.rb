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
  end # refine String
end # NRSER
