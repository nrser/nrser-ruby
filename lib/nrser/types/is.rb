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


# Type satisfied only by it's exact {#value} object (identity comparison
# via `#equal?`).
# 
class Is < Type
  
  # The exact value for this type.
  # 
  # @return [Object]
  # 
  attr_reader :value
  
  def initialize value, **options
    super **options
    @value = value
  end
  
  def explain
    "Is<#{ value.inspect }>"
  end
  
  def test? value
    @value.equal? value
  end
  
  def == other
    equal?(other) ||
    ( self.class.equal?( other.class ) &&
      @value.equal?( other.value ) )
  end


  def default_symbolic
    "{#{ value.inspect }}"
  end
  
end # Is


# @!group Identity Equality Type Factories
# ----------------------------------------------------------------------------

#@!method self.Is **options
#   Satisfied by the exact value only (identity comparison via `#equal?`).
#   
#   Useful for things like {Module}, {Class}, {Fixnum}, {Symbol}, `true`, etc.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :Is,
  parameterize: :value,
&->( value, **options ) do
  Is.new value, **options
end # .Is

# @!endgroup Identity Equality Type Factories # ******************************


# /Namespace
# ========================================================================

end # module Types
end # module NRSER
