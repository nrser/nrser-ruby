require 'pathname'

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
  
  refine Pathname do
    # override to accept Pathname instances.
    # 
    # @param [String] *prefixes
    #   the prefixes to see if the Pathname starts with.
    # 
    # @return [Boolean]
    #   true if the Pathname starts with any of the prefixes.
    # 
    def start_with? *prefixes
      to_s.start_with? *prefixes.map(&:to_s)
    end
    
    # override sub to support Pathname instances as patterns.
    # 
    # @param [String | Regexp | Pathname] pattern
    #   thing to replace.
    # 
    # @param [String | Hash] replacement
    #   thing to replace it with.
    # 
    # @return [Pathname]
    #   new Pathname.
    # 
    def sub pattern, replacement
      case pattern
      when Pathname
        super pattern.to_s, replacement
      else
        super pattern, replacement
      end
    end
  end # Pathname
end # NRSER
