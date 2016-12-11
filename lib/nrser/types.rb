require 'nrser/refinements'
require 'nrser/types/type'
require 'nrser/types/is'
require 'nrser/types/is_a'
require 'nrser/types/where'
require 'nrser/types/combinators'
require 'nrser/types/maybe'
require 'nrser/types/attrs'

using NRSER
  
module NRSER::Types
  # make a type.
  def self.make value
    if value.is_a? NRSER::Types::Type
      value
    elsif value.is_a? ::Class
      IsA.new value
    else
      Is.new value
    end
  end
  
  # raise an error if value doesn't match type.
  def self.check value, type
    make(type).check(value)
  end
   
end # NRSER::Types

# things that define values, which may need to call the functions defined
# above
require 'nrser/types/any'
require 'nrser/types/booleans'
require 'nrser/types/numbers'
require 'nrser/types/strings'