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

# Want to mix logging in
require 'nrser/log'


# Namespace
# ========================================================================

module  NRSER


# Definitions
# ========================================================================

# Stuff to help you define, test, check and match types in Ruby.
# 
# Read the documentation {file:lib/nrser/types/README.md here}.
# 
module Types
  
  # Sub-Tree Requirements
  # ========================================================================
  
  require_relative './types/type'
  require_relative './types/factory'
  
  
  # Mixins
  # ========================================================================
  
  # Add `.def_type` to define type factories
  extend Factory

  # Add `.logger` and `#logger`.
  include NRSER::Log::Mixin
  
  
  # Constants
  # ========================================================================
  
  L_PAREN = '(' # '❪'
  R_PAREN = ')' # '❫'
  RESPONDS_WITH = '→' # '->'
  ASSOC = '=>' # terrible, don't use: '⇒'
  LEQ = '≤'
  GEQ = '≥'
  COMPLEXES = 'ℂ'
  REALS = 'ℝ'
  INTEGERS = 'ℤ'
  RATIONALS = 'ℚ'
  UNION = '∪'
  AND = '&'
  NOT = '¬' # '~'
  COMPLEMENT = '∖'
  
  
  # Module Methods
  # ========================================================================
  
  # Make a {NRSER::Types::Type} from a value.
  # 
  # If the `value` argument...
  # 
  # 1.  Is a {NRSER::Types::Type}, it is returned.
  #     
  # 2.  Is a {Class}, a new {NRSER::Types::IsA} matching that class is returned.
  #     
  #     This allows things like
  #     
  #         NRSER::Types.check 's', String
  #         NRSER::Types.match 's', String, ->(s) { ... }
  #     
  # 3.  Responds to `#to_type` (and `try_to_type` is `true`), and 
  #     `value.to_type`'s response is a {NRSER::Types::Type}, that response
  #     is returned.
  #     
  # 4.  Anything else, a new {NRSER::Types::WHen} matching that value is
  #     returned.
  # 
  # @param [Object] value
  # 
  # @return [NRSER::Types::Type]
  # 
  def self.make value, try_to_type: true
    return self.Nil if value.nil?
    
    return value if value.is_a?( NRSER::Types::Type )
    
    if try_to_type && value.respond_to?( :to_type )
      begin
        type = value.to_type
      rescue
        # pass
      else
        return type if type.is_a?( NRSER::Types::Type )
      end
    end
    
    self.When value
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
  

  # Old bang-less name for {.check!}. We like out bangs around here.
  # 
  # @deprecated
  # 
  # @param    (see .check!)
  # @return   (see .check!)
  # @raise    (see .check!)
  # 
  def self.check value, type
    logger.deprecated \
      method: __method__,
      alternative: "NRSER::Types.check!"
    
    check! value, type
  end
  
  
  # Create a {NRSER::Types::Type} from `type` with {.make} and test if
  # `value` satisfies it.
  # 
  # @param [Object] value
  #   Value to test for membership.
  # 
  # @param [TYPE] type
  #   Type to see if value satisfies. Passed through {.make} to make sure it's
  #   a {Type} first.
  # 
  # @return [Boolean]
  #   `true` if `value` satisfies `type`.
  # 
  def self.test? value, type
    make(type).test value
  end
  
  
  # Old question-less name for {.test?}. We like our marks around here.
  # 
  # @param  (see .test?)
  # @return (see .test?)
  # @raise  (see .test?)
  # 
  def self.test value, type
    logger.deprecated \
      method: __method__,
      alternative: "NRSER::Types.test?"
    
    test? value, type
  end # .test

  # Old name
  singleton_class.send :alias_method, :test, :test?
  
  
  # My own shitty version of pattern matching!
  # 
  # @todo
  #   Doc this crap.
  #   
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
  
end # module Types


# /Namespace
# ========================================================================

end # module NRSER


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
require_relative './types/attributes'
require_relative './types/in'

require_relative './types/when'
require_relative './types/top'
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
require_relative './types/collections'
require_relative './types/shape'
require_relative './types/selector'
require_relative './types/enumerables'
