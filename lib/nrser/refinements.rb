module NRSER
  module KernelRefinements
    def tpl *args
      NRSER::template *args
    end
  end

  refine Object do
    include KernelRefinements

    def pipe
      yield self
    end

  end

  refine String do
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
end # NRSER