require 'pathname'

module NRSER  
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
    
    
    # Just returns `self`. Implemented to match the {String#to_pn} API so it
    # can be called on an argument that may be either one.
    # 
    # @return [Pathname]
    # 
    def to_pn
      Pathname.new self
    end
    
  end # Pathname
end # NRSER
