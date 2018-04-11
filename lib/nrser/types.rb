# encoding: UTF-8
# frozen_string_literal: true

# Abstract infrastructure for type creation - stuff that doesn't define any
# concrete type instances.
# 
# Files that define concrete type instances on load (usually as module
# constants, which I'm still questioning a bit as a design because of the
# uncontrollable mutability of Ruby and the importance of type checks)
# need to be required in the "Post-Processing" section at the bottom.
# 

require 'nrser/logging'

# Stuff to help you define, test, check and match types in Ruby.
# 
# {include:file:lib/nrser/types/README.md}
# 
module NRSER::Types
  
  # Sub-Tree Requirements
  # ========================================================================
  
  require_relative './types/type'
  require_relative './types/factory'
  
  
  # Mixins
  # ========================================================================
  
  extend Factory
  include NRSER::Logging::Mixin
  
  
  # Constants
  # ========================================================================
  
  L_PAREN = '(' # '❪'
  R_PAREN = ')' # '❫'
  RESPONDS_WITH = '→'
  ASSOC = '=>'
  
  
  # Module Methods
  # ========================================================================
  
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
    if value.nil?
      self.nil
    elsif value.is_a? NRSER::Types::Type
      value
    else
      self.when value
    end
  end
  
  
  # The {.make} method reference; for easy map and such.
  # 
  # @return [Method]
  # 
  def self.maker
    method :make
  end
  
  
  # Create a {NRSER::Types::Type} from `type` with {.make} and check that
  # `value` satisfies it, raising if it doesn't.
  # 
  # @param [*] value
  #   Value to type check.
  # 
  # @param [*] type
  #   Type to check value against.
  # 
  # @return
  #   The `value` parameter.
  # 
  # @raise [NRSER::Types::CheckError]
  #   If the value fails the type check.
  # 
  def self.check! value, type
    make( type ).check! value
  end
  
  # Old name
  singleton_class.send :alias_method, :check, :check!
  
  
  # Create a {NRSER::Types::Type} from `type` with {.make} and test if
  # `value` satisfies it.
  # 
  # @return [Boolean]
  #   `true` if `value` satisfies `type`.
  # 
  def self.test? value, type
    make(type).test value
  end
  
  # Old name
  singleton_class.send :alias_method, :test, :test?
  
  
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
      if test? value, type
        # OK, we matched! Is the corresponding expression callable?
        if expression.respond_to? :call
          # It is; invoke and return result.
          if expression.arity == 0
            return expression.call
          else
            return expression.call value
          end
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
      
          #{ enum.map {|type, expression| "\n    #{ type.inspect }"}.join '' }
      
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
        raise NotImplementedError, "Haven't gotten to it yet!"
      },
    }
  end # .from_repr
  
end # NRSER::Types


# Post-Processing
# =======================================================================
# 
# Files that define constants that need the proceeding infrastructure.
# 

require_relative './types/is'
require_relative './types/nil'
require_relative './types/is_a'
require_relative './types/where'
require_relative './types/combinators'
require_relative './types/maybe'
require_relative './types/attrs'
require_relative './types/in'

require_relative './types/when'
require_relative './types/any'
require_relative './types/booleans'

# Requires `booleans`
require_relative './types/responds'

require_relative './types/numbers'
require_relative './types/strings'
require_relative './types/symbols'
require_relative './types/labels'
require_relative './types/arrays'
require_relative './types/hashes'
require_relative './types/paths'
require_relative './types/tuples'
require_relative './types/pairs'
require_relative './types/trees'
require_relative './types/shape'
