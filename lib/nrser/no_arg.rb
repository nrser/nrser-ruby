require 'singleton'

module NRSER
  # A singleton class who's instance is used to denote the lack of value 
  # for an argument when used as the default.
  # 
  # For situations where an argument is optional and `nil` is a legitimate
  # value.
  # 
  class NoArg
    include Singleton
  end
  
  NO_ARG = NoArg.instance
end # module NRSER
