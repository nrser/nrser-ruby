module NRSER
  refine Exception do
    def format
      NRSER.format_exception self
    end
  end
  
  refine Exception.singleton_class do
  
    # Create a new instance from the squished message.
    # 
    # See {NRSER.squish}.
    # 
    # @param [String] message
    # 
    # @return [Exception]
    # 
    def squished message
      new message.squish
    end
    
    # Create a new instance from the dedented message.
    # 
    # See {NRSER.dedent}.
    # 
    # @param [String] message
    # 
    # @return [Exception]
    # 
    def dedented message
      new message.dedent
    end
    
  end # refine Exception.singleton_class
end # NRSER
