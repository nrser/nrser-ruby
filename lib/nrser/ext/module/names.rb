# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Deps
# -----------------------------------------------------------------------

# Need {String#demodulize}
require 'active_support/core_ext/string/inflections'


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# =======================================================================

module Module

  # @!group Names Instance Methods
  # --------------------------------------------------------------------------
  
  # Like {Module#name} but also returns a {String} for anonymous classes.
  # 
  # So you don't need to do any testing or trying when you want to work
  # with the name of a module (or class, which are modules).
  # 
  # @return [String]
  # 
  def safe_name
    name = self.name
    return name if name.is_a? ::String

    puts "self.name: #{ self.name.inspect } (#{ self.name.class })"
    
    # Slice out whatever that hex thingy that anon modules dump in their
    # `#to_s`... `"#<Class:0x00007fa6958c1700>" => "0x00007fa6958c1700"`
    # 
    # Might as well use that as an identifier so it matches their `#to_s`,
    # and this should still succeed in whatever funky way even if `#to_s`
    # returns something totally unexpected.
    # 
    to_s_hex = self.to_s.split( ':' ).last[0...-1]
    
    type_name = if self.is_a?( ::Class ) then "Class" else "Module" end
    
    "Anon#{ type_name }_#{ to_s_hex }"
  end # #safe_name
  
  
  # Get the {#safe_name} and run ActiveSupport's {String#demodulize} on it
  # to get the module (or class) name without the namespace.
  # 
  # @example
  #   NRSER::Types.demod_name
  #   # => 'Types'
  # 
  # @return [String]
  # 
  def demodulize_name
    safe_name.demodulize
  end # #demodulize_name
  
  # Because I always screw up spelling 'demodulize'
  alias_method :demod_name, :demodulize_name
  
  # @!endgroup Names Instance Methods # **************************************
  
end # module Module


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
