# Requirements
# =======================================================================

# Stdlib
# ---------------------------------------------------------------------

# TODO Not sure if this needs to be here... can't find any usage of it in 
#       quick searches, but I don't want to remove it now.
require 'pp'

# Deps
# ---------------------------------------------------------------------

# Package
# ---------------------------------------------------------------------

# Abstract infrastructure for type creation - stuff that doesn't define any
# concrete type instances.
# 
# Files that define concrete type instances on load (usually as module 
# constants, which I'm still questioning a bit as a design because of the
# uncontrollable mutability of Ruby and the importance of type checks)
# need to be required in the "Post-Processing" section at the bottom.
# 
require_relative './types/type'
require_relative './types/is'
require_relative './types/is_a'
require_relative './types/where'
require_relative './types/combinators'
require_relative './types/maybe'
require_relative './types/attrs'
require_relative './types/responds'


# Refinements
# =======================================================================

require 'nrser/refinements'
using NRSER


# Stuff to help you define, test, check and match types in Ruby.
# 
# {include:file:lib/nrser/types/README.md}
# 
module NRSER::Types
  
  # Make a {NRSER::Types::Type} from a value.
  # 
  # If the `value` argument is...
  # 
  # -   a {NRSER::Types::Type}, it is returned.
  #     
  # -   a {Class}, a new {NRSER::Types::IsA} matching that class is returned.
  #     
  #     This allows things like
  #     
  #         NRSER::Types.check 's', String
  #         NRSER::Types.match 's', String, ->(s) { ... }
  # 
  # -   anything else, a new {NRSER::Types::Is} matching that value is
  #     returned.
  # 
  # @param [Object] value
  # 
  # @return [NRSER::Types::Type]
  # 
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
  end # .match
  
  
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
  end # .from_repr
  
end # NRSER::Types


# Post-Processing
# =======================================================================
# 
# Files that define constants that need the proceeding infrastructure.
# 

require_relative './types/any'
require_relative './types/booleans'
require_relative './types/numbers'
require_relative './types/strings'
require_relative './types/symbols'
require_relative './types/labels'
require_relative './types/array'
require_relative './types/hash'
require_relative './types/paths'
require_relative './types/tuples'
require_relative './types/pairs'
