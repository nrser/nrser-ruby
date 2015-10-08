module NRSER
  refine Object do
    def pipe
      yield self
    end
  end

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

  refine Exception do
    def format
      NRSER.format_exception self
    end
  end
  
  refine Binding do
    def erb str
      NRSER.template self, str
    end
  end
end # NRSER
