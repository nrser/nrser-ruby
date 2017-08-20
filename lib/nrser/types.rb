require 'pp'

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
    make(type).check value
  end
  
  def self.test value, type
    make(type).test value
  end
  
  def self.match value, type_map
    type_map.each {|type, block|
      if test value, type
        return block.call value
      end
    }
    
    raise TypeError, <<-END.dedent
      could not match value
      
        #{ value.inspect }
      
      to any of types
      
          #{ type_map.keys.map {|type| "\n    #{ type.inspect }"} }
      
    END
  end
  
  # make a type instance from a object representation that can come from 
  # a YAML or JSON declaration.
  def self.from_repr repr
    match repr, {
      str => ->(string) {
        NRSER::Types.method(string.downcase).call
      },
      
      Hash => ->(hash) {
        
      },
    }
  end
end # NRSER::Types

# things that define values, which may need to call the functions defined
# above
require 'nrser/types/any'
require 'nrser/types/booleans'
require 'nrser/types/numbers'
require 'nrser/types/strings'
require 'nrser/types/symbol'
require 'nrser/types/array'
require 'nrser/types/hash'