# encoding: UTF-8
# frozen_string_literal: true
# doctest: true


# Namespace
# ========================================================================

module  NRSER


# Definitions
# ========================================================================

# 
# Many simple examples are given as part of method documentation, and any 
# detailed tests or guides available as Cucumber features are linked.
# 
# You can view all Cucumber features for the module here: 
# {requirements::features::lib::nrser::booly NRSER::Booly features}.
# 
# Both YARD examples and Cucumber features are verified programmatically, with 
# results on the [Travis CI site][].
# 
# [Travis CI site]: https://travis-ci.org/nrser/nrser.rb
# 
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
    'nil',
    'null',
    'none',
  ].freeze
  
  
  # Singleton Methods
  # ========================================================================
  
  # @!group String Singleton Methods
  # --------------------------------------------------------------------------
  
  # Is an `object` a *truthy* {::String}?
  # 
  # I.E. is it a {::String} and when {::String#downcase}ed is it in 
  # {TRUTHY_STRINGS}?
  # 
  # Check out the Cucumber
  # {requirements::features::lib::nrser::booly::testing_strings features}
  # for details.
  # 
  # @note
  #   This is **not** the negation of {.falsy_string?}.
  #   
  #   Most {::String} instances are neither *truthy* or *falsy*.
  # 
  # @pure Return value depends only on parameters.
  # 
  # @param [::Object] object
  # 
  # @return [Boolean]
  #   `true` if `object` is a {::String} *and* it's a *truthy* one.
  # 
  def self.truthy_string? object
    return false unless object.is_a?( ::String )
    
    TRUTHY_STRINGS.include? object.downcase
  end # .truthy_string?
  
  
  # Is an `object` a *falsy* {::String}?
  # 
  # I.E. is it a {::String} and when {::String#downcase}ed is it in 
  # {FALSY_STRINGS}?
  # 
  # Check out the Cucumber
  # {requirements::features::lib::nrser::booly::testing_strings features
  # for details.
  # 
  # @note
  #   This is **not** the negation of {.truthy_string?}.
  #   
  #   Most {::String} instances are neither *truthy* or *falsy*.
  # 
  # @pure Return value depends only on parameters.
  # 
  # @param [::Object] object
  # 
  # @return [Boolean]
  #   `true` if `object` is a {::String} *and* it's a *truthy* one.
  # 
  def self.falsy_string? object
    return false unless object.is_a?( ::String )
    
    FALSY_STRINGS.include? object.downcase
  end # .truthy_string?
  
  
  # Is `object` either a {.truthy_string?} *or* a {.falsy_string?}?
  # 
  # Check out the Cucumber
  # {requirements::features::lib::nrser::booly::testing_strings features}
  # for details.
  # 
  # @pure Return value depends only on parameters.
  # 
  # @param [::Object] object
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.booly_string? object
    truthy_string?( object ) || falsy_string?( object )
  end # .string?
  
  
  # Get the corresponding boolean for a {::String} (if it is a {::String} and
  # does correspond to one, otherwise returns `nil`).
  # 
  # @pure Return value depends only on parameters.
  # 
  # @param [::String] string
  #   Actually, you can pass anything, but you will *always* get `nil` back if
  #   it's not a {::String}.
  # 
  # @return [nil]
  #   If `string` is not a {::String} or if it's neither *truthy* or *falsy*.
  # 
  # @return [Boolean]
  #   `true` if `string` is a {.truthy_string?}; `false` if `string` is a 
  #   {.falsy_string?}.
  # 
  def self.from_string string
    return nil unless string.is_a?( ::String )
  
    if truthy_string? string
      true
    elsif falsy_string? string
      false
    else
      nil
    end
  end # .from_string
  
  # @!endgroup String Singleton Methods # *******************************
  
  
  # @!group Integer Singleton Methods
  # --------------------------------------------------------------------------
  
  # Is an `object` a *truthy* {::Integer} (also known as `1`)?
  # 
  # I.E. is object exactly `1`? This is an identity comparison with `#equal?`.
  # 
  # This is to support C-style booleans, which uses `1` for `true` and `0` for
  # `false`.
  # 
  # @note
  #   This is **not** the negation of {.falsy_integer?}.
  # 
  # @example `1` is the **only** *truthy* integer
  #   truthy_integer? 1
  #   #=> true
  # 
  # @example `1`-like floats are not *truthy* integers
  #   truthy_integer? 1.0
  #   #=> false
  # 
  # @pure Return value depends only on parameters.
  # 
  # @param [::Object] object
  # 
  # @return [Boolean]
  #   `true` if `object` is `1`.
  # 
  def self.truthy_integer? object
    object.equal? 1
  end # .truthy_integer?
  
  
  # Is an `object` a *falsy* {::Integer} (also known as `0`)?
  # 
  # I.E. is object exactly `0`? This is an identity comparison with `#equal?`.
  # 
  # This is to support C-style booleans, which uses `1` for `true` and `0` for
  # `false`.
  # 
  # @note
  #   This is **not** the negation of {.truthy_integer?}.
  # 
  # @example `0` is the **only** *falsy* integer
  #   falsy_integer? 0
  #   #=> true
  # 
  # @example `0`-like floats are not *falsy* integers
  #   falsy_integer? 0.0
  # 
  # @pure Return value depends only on parameters.
  # 
  # @param [::Object] object
  # 
  # @return [Boolean]
  #   `true` if `object` is `1`.
  # 
  def self.falsy_integer? object
    object.equal? 0
  end # .falsy_integer?
  
  # @!endgroup Integer Singleton Methods # ******************************
  

  # Is an `object` *truthy*? Basically a catch-all for "if someone might have
  # thought this meant `true`, I want it to mean `true`". Otherwise, it will 
  # return `false`.
  # 
  # @note
  #   ### IMPORTANT! ###
  #   
  #   This is **not** the negation of {.falsy?} and it does *not* operate at 
  #   like `if object`: only `true` and very specific {::Integer}, {::String}
  #   and {::Symbol} instances will return `true`!
  #   
  #   Read it carefully. Really.
  # 
  # Basically just a switch on `object`'s class:
  # 
  #   -   `true` returns `true`.
  #       
  #   -   {::Integer} are forwarded to {.truthy_integer?}.
  #       
  #   -   {::String} are forwarded to {.truthy_string?}.
  #       
  #   -   {::Symbol} are converted to {::String}, then forwarded to 
  #       {.truthy_string?}
  #   
  #   -   Everything else returns `false`.
  # 
  # @example `true` is *truthy*
  #   truthy? true
  #   #=> true
  # 
  # @example `1` is *truthy*
  #   truthy? 1
  #   #=> true
  #   
  # @example Strings in {TRUTHY_STRINGS} are *truthy*
  #   truthy? "yes"
  #   #=> true
  # 
  # @example Strings are case-insensitive
  #   truthy? "YeS"
  #   #=> true
  # 
  # @example Symbols are compared as strings
  #   truthy? :yes
  #   #=> true
  # 
  # @example Everything else is not *truthy* (returning `false`)
  #   truthy? 123
  #   #=> false
  # 
  # @pure Return value depends only on parameters.
  # 
  # @param [::Object] object
  #   Value to test.
  # 
  # @return [Boolean]
  #   `true` if the object is *truthy* (see above). Everything else is `false`.
  # 
  def self.truthy? object
    case object
    when true
      true
    when ::Integer
      truthy_integer? object
    when ::Symbol
      truthy_string? object.to_s
    when ::String
      truthy_string? object
    else
      false
    end
  end # .truthy?
  
  
  # Is an `object` *falsy*? Basically a catch-all for "if someone might have
  # thought this meant `false`, return `true`". Otherwise, it will 
  # return `false`.
  # 
  # @note
  #   ### IMPORTANT! ###
  #   
  #   This is **not** the negation of {.falsy?} and it does *not* operate at 
  #   like `if object`: only `true` and very specific {::Integer}, {::String}
  #   and {::Symbol} instances will return `true`!
  #   
  #   Read it carefully. Really.
  # 
  # Basically just a switch on `object`'s class:
  # 
  #   -   `nil` and `false` return `true`.
  #       
  #   -   {::Integer} are forwarded to {.falsy_integer?}.
  #       
  #   -   {::String} are forwarded to {.falsy_string?}.
  #       
  #   -   {::Symbol} are converted to {::String}, then forwarded to 
  #       {.falsy_string?}
  #   
  #   -   Everything else returns `false`.
  # 
  # @example `nil` and `false` are *falsy*
  #   
  #   falsy? nil
  #   #=> true
  #   
  #   falsy? false
  #   #=> true
  # 
  # @example `0` is *falsy*
  #   falsy? 0
  #   #=> true
  #   
  # @example Strings in {TRUTHY_STRINGS} are *falsy*
  #   falsy? "f"
  #   #=> true
  # 
  # @example Strings are case-insensitive
  #   falsy? "NuLL"
  #   #=> true
  # 
  # @example Symbols are compared as strings
  #   falsy? :no
  #   #=> true
  # 
  # @example Everything else is not *falsy* (returning `false`)
  #   falsy? 123
  #   #=> false
  # 
  # @pure Return value depends only on parameters.
  # 
  # @param [::Object] object
  #   Value to test.
  # 
  # @return [Boolean]
  #   `true` if the object is *falsy* (see above). Everything else is `false`.
  # 
  def self.falsy? object
    case object
    when nil, false
      true
    when ::Integer
      falsy_integer? object
    when ::Symbol
      falsy_string? object.to_s
    when ::String
      falsy_string? object
    else
      false
    end
  end # .falsy?
  
  
  # Convert {.truthy?} things to `true`, {.falsy?} things to `false`, and 
  # everything else to `nil`.
  # 
  # @example
  #   from 'true'
  #   #=> true
  #   
  #   from 'f'
  #   #=> false
  #   
  #   from 'whatever'
  #   #=> nil
  # 
  # @param [::Object] object
  #   Value to convert.
  # 
  # @return [true]
  #   When `object` is {#truthy?}.
  # 
  # @return [false]
  #   When `object` is {#falsy?}.
  # 
  # @return [nil]
  #   When `object` is neither {#truthy?} or {#falsy?}.
  # 
  def self.from object
    if truthy? object
      true
    elsif falsy? object
      false
    else
      nil
    end
  end # .from
  
  
  # Like {.from} but raises an error if `object` isn't *truthy* or *falsy* 
  # (instead of returning `nil`).
  # 
  # @example
  #   from! 'true'
  #   #=> true
  #   
  #   from! 'f'
  #   #=> false
  #   
  #   from! 'whatever'
  #   #=> raise ::ArgumentError, %(Not booly: "whatever" (String))
  # 
  # @param [::Object] object
  #   Value to convert.
  # 
  # @return [true]
  #   When `object` is {#truthy?}.
  # 
  # @return [false]
  #   When `object` is {#falsy?}.
  # 
  # @raise [::ArgumentError]
  #   When `object` is neither {#truthy?} or {#falsy?}.
  # 
  def self.from! object
    from( object ).tap do |response|
      if response.nil?
        raise ::ArgumentError,
          "Not booly: #{ object.inspect } (#{ object.class })"
      end
    end
  end # .from!

end # module Booly


# /Namespace
# ========================================================================

end # module NRSER
