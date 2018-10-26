# frozen_string_literal: true
# encoding: UTF-8

# Requirements
# ========================================================================

# Deps
# ------------------------------------------------------------------------

# Using {String#constantize}, {String#safe_constantize}
require 'active_support/core_ext/string/inflections'


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# ========================================================================

module String

  # @!group Inflection Instance Methods
  # --------------------------------------------------------------------------
  
  # Alias for {ActiveSupport}'s {String#safe_constantize}, which returns `nil`
  # when it fails.
  # 
  # This alias pairs with {#to_const!} to present an interface in line with the
  # "bang throws, no-bang `nil`s" convention.
  # 
  # @see https://edgeguides.rubyonrails.org/active_support_core_extensions.html#constantize
  # @see https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-safe_constantize
  # 
  # @return [nil]
  #   When `self` is not CamelCase or not an initialized constant name.
  # 
  # @return [Object]
  #   The constant named `self`.
  # 
  def to_const
    safe_constantize
  end
  

  # Alias for {ActiveSupport}'s {String#constantize}, which returns `nil`
  # when it fails.
  # 
  # This alias pairs with {#to_const!} to present an interface in line with the
  # "bang throws, no-bang `nil`s" convention.
  # 
  # @see https://edgeguides.rubyonrails.org/active_support_core_extensions.html#constantize
  # @see https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-constantize
  # 
  # @return [Object]
  #   The constant named `self`.
  # 
  # @raise [NameError]
  #   When `self` is not CamelCase or not an initialized constant name.
  # 
  def to_const!
    constantize
  end

  # @!endgroup Inflection Instance Methods # *********************************
  
end # module String


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
