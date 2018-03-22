class Exception
  def format
    NRSER.format_exception self
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
    new NRSER.squish( message )
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
    new NRSER.dedent( message )
  end
  
end # NRSER
