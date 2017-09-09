require 'pp'

require 'nrser/refinements'
require 'nrser/types/type'
require 'nrser/types/is'
require 'nrser/types/is_a'
require 'nrser/types/where'
require 'nrser/types/combinators'
require 'nrser/types/maybe'
require 'nrser/types/attrs'
require 'nrser/types/responds'

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
  
  def self.match value, *clauses
    if clauses.empty?
      raise ArgumentError.new NRSER.dedent <<-END
        Must supply either a single {type => expression} hash argument or a
        even amount of arguments representing (type, expression) pairs after
        `value`.
        
        #{ NRSER::Version.doc_url 'NRSER/Types#match-class_method' }
      END
    end
    
    enum = if clauses.length == 1 && clauses.first.respond_to?(:each_pair)
      clauses.first.each_pair
    else
      unless clauses.length % 2 == 0
        raise TypeError.new NRSER.dedent <<-END
          When passing a list of clauses, it must be an even length
          representing (type, expression) pairs.
          
          Found an argument list with length #{ clauses.length }:
          
          #{ clauses }
        END
      end
      
      clauses.each_slice(2)
    end
    
    enum.each { |type, expression|
      if test value, type
        # OK, we matched! Is the corresponding expression callable?
        if expression.respond_to? :call
          # It is; invoke and return result.
          return expression.call value
        else
          # It's not; assume it's a value and return it.
          return expression
        end
      end
    }
    
    raise TypeError, <<-END.dedent
      Could not match value
      
          #{ value.inspect }
      
      to any of types
      
          #{ enum.map {|type, expression| "\n    #{ type.inspect }"} }
      
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