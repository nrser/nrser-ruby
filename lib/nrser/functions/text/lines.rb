module NRSER
  # @!group Text Functions
  
  def self.lines text
    case text
    when String
      text.lines
    when Array
      text
    else
      raise TypeError,
        "Expected String or Array, found #{ text.class.safe_name }"
    end
  end
  
end # module NRSER
