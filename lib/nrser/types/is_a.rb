# frozen_string_literal: true
# encoding: UTF-8


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require 'nrser/types/type'


# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# ========================================================================

# Type satisfied by class membership (or mixin presence for modules).
# 
# Tests via the subject value's `#is_a?` method is `true` for {#mod}. Works
# for class instances as will as mixins.
#
# @note
#   Construct {IsA} types using the {.IsA} factory.
# 
class IsA < NRSER::Types::Type
  attr_reader :mod
  
  def initialize mod, init_from_data: false, **options
    unless mod.is_a?( Module )
      raise ArgumentError,
        "`mod` argument must be a Module (inc. Class), " \
        "received #{ mod.inspect }"
    end
    
    super **options
    
    @init_from_data = !!init_from_data
    
    @mod = mod
  end
  
  
  def explain
    mod.safe_name
  end
  
  
  def test? value
    value.is_a? mod
  end
  
  
  def init_from_data?
    @init_from_data
  end # #init_from_data?
  
  
  # Forwards to `mod.from_data`.
  # 
  # @param data (see NRSER::Types::Type#from_data)
  # @return     (see NRSER::Types::Type#from_data)
  # @raise      (see NRSER::Types::Type#from_data)
  # 
  def custom_from_data data
    if init_from_data?
      mod.new data
    else
      mod.from_data data
    end
  end
  
  
  # Overrides {NRSER::Types::Type#has_from_data?} to respond `true` when
  # there is a instance-specific `@from_data` or the {#mod} responds to
  # `.from_data`.
  # 
  # @return [Boolean]
  # 
  def has_from_data?
    @from_data ||
      init_from_data? ||
      mod.respond_to?( :from_data )
  end
  
  
  def == other
    equal?( other ) ||
    ( self.class == other.class &&
      self.mod == other.mod )
  end
  
end # class IsA


# @!group Class Instance Type Factories
# ----------------------------------------------------------------------------

# @!method self.IsA module_, **options
#   Create a type
#   
#       { x : x.is_a?( mod ) == true }
#   
#   If `mod` is a {Class}, the returned {Type} will be satisfied by instances
#   of `mod`.
#   
#   If `mod` is a non-Class {Module}, the returned {Type} will be satisfied
#   by instances of classes that include `mod`.
#   
#   @param [Module] module_
#     The {Class} or {Module} that type members should be.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
# 
def_type        :IsA,
  parameterize: :mod,
&->( module_, **options ) do
  IsA.new module_, **options
end


#@!method self.Type **options
#   A type whose members are {Type} instances themselves.
#   
#   @todo
#     This is where the methods that load types from data and strings that 
#     are used by CLI apps to spec params and the like should go!
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [IsA]
#   
def_type        :Type,
&->( **options ) do
  IsA NRSER::Types::Type, **options
end # .Type

# @!endgroup Class Instance Type Factories # *********************************


# /Namespace
# ========================================================================

end # module Types
end # module NRSER
