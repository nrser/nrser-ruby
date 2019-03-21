# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# ========================================================================

module  NRSER


# Definitions
# ========================================================================

module Booly

  # Constants
  # ============================================================================
  
  # Down-cased versions of strings that are considered to communicate true
  # in things like ENV vars, CLI options, etc.
  # 
  # @return [Set<String>]
  # 
  TRUTHY_STRINGS = Set.new [
    'true',
    't',
    'yes',
    'y',
    'on',
    '1',
  ].freeze
  
  
  # Down-cased versions of strings that are considered to communicate false
  # in things like ENV vars, CLI options, etc.
  # 
  # @return [Set<String>]
  # 
  FALSY_STRINGS = Set.new [
    'false',
    'f',
    'no',
    'n',
    'off',
    '0',
    '',
  ].freeze
  
  
  # Singleton Methods
  # ========================================================================

  # Evaluate an object (that probably came from outside Ruby, like an
  # environment variable) to see if it's meant to represent true or false.
  # 
  # @pure Return value depends only on parameters.
  # 
  # @param [nil | String | Symbol | Boolean] object
  #   Value to test.
  # 
  # @return [Boolean]
  #   `true` if the object is "truthy".
  # 
  # @raise [::ArgumentError]
  #   When a string is received that is not in {TRUTHY_STRINGS} or
  #   {FALSY_STRINGS} (case insensitive), or a {::Symbol} whose string 
  #   representation falls in the same category.
  # 
  # @raise [::TypeError]
  #   When `object` is not an acceptable type.
  # 
  def self.truthy? object
    if object.is_a?( ::Symbol )
      object = object.to_s
    end
    
    case object
    when nil
      false
      
    when ::String
      downcased = object.downcase
      
      if TRUTHY_STRINGS.include? downcased
        true
      elsif FALSY_STRINGS.include? downcased
        false
      else
        raise ::ArgumentError,
              "String #{ object.inspect } not recognized as true or false."
      end
      
    when ::TrueClass, ::FalseClass
      object
      
    else
      raise ::TypeError,
            "Can't evaluate truthiness of #{ object.inspect }"
    end
  end # .truthy?
  
  
  # Opposite of {NRSER.truthy?}.
  # 
  # @pure Return value depends only on parameters.
  # 
  # @param [nil | ::String | Boolean] object
  #   Value to test.
  # 
  # @return [Boolean]
  #   `true` if the `object` is "falsy" (not "truthy").
  # 
  # @raise [::ArgumentError]
  #   When a string is received that is not in {TRUTHY_STRINGS} or
  #   {FALSY_STRINGS} (case insensitive).
  # 
  # @raise [::TypeError]
  #   When `object` is not an acceptable type.
  # 
  def self.falsy? object
    !truthy?( object )
  end # .falsy?

end # module Booly


# /Namespace
# ========================================================================

end # module NRSER
