module NRSER
  refine Exception do
    def format
      NRSER.format_exception self
    end
  end
  
  # Create a new instance from the squished message.
  # 
  # See {NRSER.squish}.
  # 
  # @param [String] message
  # 
  # @return [Exception]
  # 
  def self.squished message
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
  def self.dedented message
    new message.dedent
  end
end # NRSER
