require 'set'

module NRSER 
  # Down-cased versions of strings that are considered to communicate truth.
  TRUTHY_STRINGS = Set.new [
    'true',
    't',
    'yes',
    'y',
    'on',
    '1',
  ]
  
  # Down-cased versions of strings that are considered to communicate false.
  FALSY_STRINGS = Set.new [
    'false',
    'f',
    'no',
    'n',
    'off',
    '0',
    '',
  ]
  
  # Evaluate an object (that probably came from outside Ruby, like an
  # environment variable) to see if it's meant to represent true or false.
  # 
  # @param [Nil, String] object
  #   Value to test.
  # 
  # @return [Boolean]
  #   `true` if the object is "truthy".
  # 
  def self.truthy? object
    case object
    when nil
      false
      
    when String
      downcased = object.downcase
      
      if TRUTHY_STRINGS.include? downcased
        true
      elsif FALSY_STRINGS.include? downcased
        false
      else
        raise ArgumentError,
              "String #{ object.inspect } not recognized as true or false."
      end
      
    when TrueClass, FalseClass
      object
      
    else
      raise TypeError,
            "Can't evaluate truthiness of #{ object.inspect }"
    end
  end # .truthy?
  
  
  # Opposite of {NRSER.truthy?}.
  # 
  # @param object (see .truthy?)
  # 
  # @return [Boolean]
  #   The negation of {NRSER.truthy?}.
  # 
  def self.falsy? object
    ! truthy?(object)
  end # .falsy?
  
end # module NRSER
