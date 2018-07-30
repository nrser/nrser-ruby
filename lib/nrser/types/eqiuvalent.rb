# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require_relative './type'


# Namespace
# ========================================================================

module  NRSER
module  Types


# Type satisfied only by anything `#==` it's {#value}.
# 
class Equivalent < Type
  
  # Attributes
  # ========================================================================
  
  attr_reader :value
  
  def initialize value, **options
    super **options
    @value = value
  end
  

  def explain
    "Equivalent<#{ value.inspect }>"
  end
  

  def test? value
    @value.equal? value
  end
  

  def == other
    equal?(other) ||
    ( self.class == other.class &&
      @value == other.value )
  end


  def default_symbolic
    "{ x : #{ value.inspect }==x }"
  end
  
end # class Equivalent


# @!group Equivalent Type Factories
# ----------------------------------------------------------------------------

# @!method self.Equivalent value, **options
#   Satisfied by values that `value` is `#==` to (`{ x : value == x }`).
#   
#   @param [Object] value
#     Value that all members of the type will be equal to.
# 
#   @param [Hash] **options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#     A type whose members are all instances of Ruby's {Numeric} class.
# 
def_type        :Equivalent,
  aliases:    [ :eq ],
  parameterize: :value,
&->( value, **options|
  Equivalent.new value, **options
end

# @!endgroup Equivalent Type Factories # *************************************


# /Namespace
# ========================================================================

end # module Types
end # module NRSER
