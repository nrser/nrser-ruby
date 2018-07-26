# encoding: UTF-8
# frozen_string_literal: true

require 'nrser/types/type'



# Namespace
# ========================================================================

module  NRSER
module  Types


# Abstract Base Class
# ============================================================================

# Abstract base class for logically combining types to create new ones.
# 
# @see Union
# @see Intersection
# 
class Combinator < Type
  
  # The parametrized types, in the order they will be tested.
  # 
  # @return [Array<NRSER::Types::Type>]
  # 
  attr_reader :types
  
  
  def initialize *types, **options
    super **options
    @types = types.map { |type| NRSER::Types.make type }.freeze
  end
  
  
  def explain
    if self.class::JOIN_SYMBOL
      NRSER::Types::L_PAREN + # ' ' +
      @types.map { |type| type.explain }.join( self.class::JOIN_SYMBOL ) +
      # ' ' +
      NRSER::Types::R_PAREN
    else
      "#{ self.class.demod_name }<" +
        @types.map { |type| type.explain }.join( ',' ) +
      ">"
    end
  end
  
  
  # Parse a satisfying value from a {String} or raise a {TypeError}.
  # 
  # If this type has it's own `@from_s` that was provided via the `from_s:`
  # keyword at construction, then that and **only** that is **always** used
  # - the type will never try any of the combined types' `#from_s`.
  # 
  # It's considered *the* way to parse a string into a value that satisfies
  # the type. If it fails, a {TypeError} will be raised (or any error the
  # `@from_s` proc itself raises before we get to checking it).
  # 
  # If the type doesn't have it's own `@from_s`, each of the combined types'
  # `#from_s` will be tried in sequence, and the first value that satisfies
  # the combined type will be returned.
  # 
  # This is obviously much less efficient, but provides a nice automatic
  # mechanism for parsing from strings for combined types. If none of the
  # combined types' `#from_s` succeed (or if there are none) a {TypeError}
  # is raised.
  # 
  # @param [String] s
  #   String to parse.
  # 
  # @return [Object]
  #   Object that satisfies the type.
  # 
  # @raise [TypeError]
  #   See write up above.
  # 
  def custom_from_s s
    unless @from_s.nil?
      return check @from_s.call( s )
    end
    
    @types.each { |type|
      if type.has_from_s?
        begin
          return check type.from_s(s)
        rescue TypeError => e
          # pass
        end
      end
    }
    
    raise TypeError,
      "none of combinator #{ self.to_s } types could convert #{ s.inspect }"
  end
  
  
  # Overridden to delegate functionality to the combined types.
  # 
  # A combinator may attempt to parse from a string if:
  # 
  # 1.  It has it's own `@from_s` provided at construction.
  # 
  # 2.  Any of it's combined types can parse from a string.
  # 
  # See {#from_s} for details of how it actually happens.
  # 
  # @return [Boolean]
  # 
  def has_from_s?
    !@from_s.nil? || @types.any? { |type| type.has_from_s? }
  end # has_from_s
  
  
  def has_from_data?
    @types.any? { |type| type.has_from_data? }
  end
  
  
  # Overridden to
  def from_data data
    unless has_from_data?
      raise NoMethodError, "#from_data not defined"
    end
    
    errors = []
    
    types.each do |type|
      if type.has_from_data?
        begin
          return check!( type.from_data data )
        rescue StandardError => error
          errors << error
        end
      end
    end
    
    raise NRSER::MultipleErrors.new \
      errors,
      headline: "No type successfully loaded data"
  end
  
  
  # Overridden to delegate functionality to the combined types:
  # 
  # A combinator can convert a value to data if *any* of it's types can.
  # 
  # @return [Boolean]
  # 
  def has_to_data?
    @types.any? { |type| type.has_to_data? }
  end # #has_to_data
  
  
  # Overridden to delegate functionality to the combined types:
  # 
  # The first of the combined types that responds to `#to_data` is used to
  # dump the value.
  # 
  # @param [Object] value
  #   Value of this type (though it is *not* checked).
  # 
  # @return [Object]
  #   The data representation of the value.
  # 
  def to_data value
    @types.each { |type|
      if type.has_to_data?
        return type.to_data value
      end
    }
    
    raise NoMethodError, "#to_data not defined"
  end # #to_data
  
  
  def == other
    equal?(other) || (
      other.class == self.class && other.types == @types
    )
  end

end # class Combinator *****************************************************


# Concrete Implementation Classes
# ==========================================================================


# Union (`union`, `one_of`, `or`, `|`)
# ----------------------------------------------------------------------------

class Union < Combinator
  JOIN_SYMBOL = ' | ' # ' ⋁ '
  
  def test? value
    @types.any? { |type| type.test value }
  end
end # class Union


# match any of the types
def_factory(
  :union,
  aliases: [:one_of, :or],
) do |*types, **options|
  Union.new *types, **options
end


# Intersection (`intersection`, `all_of`, `and`, `&)
# ----------------------------------------------------------------------------

class Intersection < Combinator
  JOIN_SYMBOL = ' & ' # ' ⋀ '
  
  def test? value
    @types.all? { |type| type.test? value }
  end
end # class Intersection


# match all of the types
def_factory(
  :intersection,
  aliases: [:all_of, :and],
) do |*types, **options|
  Intersection.new *types, **options
end



# XOR - Exclusive Or (`xor`)
# ----------------------------------------------------------------------------

class XOR < Combinator
  JOIN_SYMBOL = ' ⊕ '
  
  def test? value
    @types.count { |type| type === value } == 1
  end
end


def_factory(
  :xor,
  aliases: [ :exclusive_or, :only_one_of ],
) do |*types, **options|
  XOR.new *types, **options
end
  

# /Namespace
# ========================================================================

end # module Types
end # module NRSER

