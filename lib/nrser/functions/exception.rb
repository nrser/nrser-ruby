module NRSER
  # @!group Exception Functions
  
  # String format an exception the same way they are printed to the CLI when
  # not handled (when they crash programs - what you're used to seeing),
  # including the message, class and backtrace.
  # 
  # @param [Exception] e
  #   Exception to format.
  # 
  # @return [String]
  # 
  def self.format_exception e
    "#{ e.to_s } (#{ e.class }):\n  #{ e.backtrace.join("\n  ") }"
  end
  
end # module NRSER
