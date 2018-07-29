# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

# Need truthy and falsy parse values
require 'nrser/functions/object/truthy'

require_relative './type'
require_relative './is'
require_relative './combinators'

  
# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# ========================================================================

# Abstract base class for {True} and {False}.
# 
class Boolean < Is
  
  # Instantiate a new `Boolean`.
  # 
  def initialize value, **options
    # Check it's a boolean
    unless true.equal?( value ) || false.equal?( value )
      raise ArgumentError.new \
        "`value` arg must be `true` or `false`, found #{ value.inspect }"
    end
    
    super value, **options
  end # #initialize
  
  
  protected
  # ========================================================================
    
    def custom_from_s string
      return value if self::STRINGS.include?( string.downcase )
      
      raise NRSER::Types::FromStringError.new \
        type: self,
        string: string,
        binding: binding,
        details: -> {
          <<~END
            Down-cased `string` must be one of:
            
                <%= self::STRINGS.to_a %>
          END
        }
    end
    
  public # end protected *****************************************************
  
end # class Boolean


# @!group Boolean Type Factories
# ----------------------------------------------------------------------------

# A type for only the `true`.
# 
# Provides a {#custom_from_s} to load from CLI options and ENV var-like
# string values.
# 
class True < Boolean
  
  STRINGS = NRSER::TRUTHY_STRINGS
  
  # Instantiate a new `True` type.
  # 
  def initialize **options
    super true, **options
  end # #initialize
  
end # class True


# A type for only `false`.
# 
# Provides a {#custom_from_s} to load from CLI options and ENV var-like
# string values.
# 
class False < Boolean
  
  STRINGS = NRSER::FALSY_STRINGS
  
  # Instantiate a new `True` type.
  # 
  def initialize **options
    super false, **options
  end # #initialize
  
end # class FalseType


#@!method True **options
#   A type whose only member is `true` and loads from common CLI and ENV 
#   var string representations (see {True} and {True::STRINGS}).
#   
#   @param [Hash] **options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type  :True,
&->( **options ) do
  True.new **options
end


#@!method False **options
#   A type whose only member is `false` and loads from common CLI and ENV 
#   var string representations (see {False} and {False::STRINGS}).
#   
#   @param [Hash] **options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :False,
&->( **options ) do
  False.new **options
end # .False


#@!method Boolean **options
#   {.True} or {.False}.
#   
#   @param [Hash] **options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :Boolean,
  aliases:    [ :bool ],
&->( **options ) do
  union self.True, self.False, **options
end # .Boolean

# @!endgroup Boolean Type Factories # ****************************************


# /Namespace
# ========================================================================

end # module Types
end # module NRSER
