# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# ========================================================================

module Object

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
  
  
  # Class Methods
  # ========================================================================

  # Evaluate an object (that probably came from outside Ruby, like an
  # environment variable) to see if it's meant to represent true or false.
  # 
  # @pure Return value depends only on parameters.
  # 
  # @param [nil | String | Boolean] object
  #   Value to test.
  # 
  # @return [Boolean]
  #   `true` if the object is "truthy".
  # 
  # @raise [ArgumentError]
  #   When a string is received that is not in {NRSER::TRUTHY_STRINGS} or
  #   {NRSER::FALSY_STRINGS} (case insensitive).
  # 
  # @raise [TypeError]
  #   When `object` is not the right type.
  # 
  def self.truthy? object
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
        raise ArgumentError,
              "String #{ object.inspect } not recognized as true or false."
      end
      
    when TrueClass, FalseClass
      object
      
    else
      raise TypeError,
            "Can't evaluate truthiness of #{ object.inspect }"
    end
  end # .truthy?
  
  
  # Opposite of {NRSER.truthy?}.
  # 
  # @pure Return value depends only on parameters.
  # 
  # @param object (see .truthy?)
  # 
  # @return [Boolean]
  #   The negation of {NRSER.truthy?}.
  # 
  # @raise [ArgumentError]
  #   When a string is received that is not in {NRSER::TRUTHY_STRINGS} or
  #   {NRSER::FALSY_STRINGS} (case insensitive).
  # 
  # @raise [TypeError]
  #   When `object` is not the right type.
  # 
  def self.falsy? object
    !truthy?( object )
  end # .falsy?

  
  # Instance Methods
  # ========================================================================

  # Calls {.truthy?} on `self`.
  def truthy?
    Ext::Object.truthy? self
  end
  
  
  # Calls {.falsy?} on `self`.
  def falsy?
    Ext::Object.falsy? self
  end
  
end # module Object


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
