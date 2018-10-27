# frozen_string_literal: true
# encoding: UTF-8

# Requirements
# ========================================================================

# Stdlib
# ------------------------------------------------------------------------

require 'pathname'
require 'active_support/core_ext/string/filters'

# Project / Package
# ------------------------------------------------------------------------

# Submodules
require_relative './string/sys/env'
require_relative './string/format'
require_relative './string/inflections'
require_relative './string/style'
require_relative './string/text'


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# ========================================================================

# Extension methods for {::String}.
# 
module String
  
  
  # @return [Pathname]
  #   Convert self into a {Pathname}
  # 
  def to_pn
    ::Pathname.new self
  end
  
  
  # Override {#start_with?} to accept {Regexp} prefixes.
  # 
  # I guess I always *just felt* like this should work... so now it does
  # (kinda, at least).
  # 
  # Everything should work the exact same for {String} prefixes.
  # 
  # Use {Regexp} ones at your own pleasure and peril.
  # 
  # @param [String | Regexp] prefixes
  #   Strings behave as usual per the standard lib.
  #   
  #   Regexp sources are used to create a new Regexp with `\A` at the start -
  #   unless their source already starts with `\A` or `^` - and those Regexp
  #   are tested against the string.
  #   
  #   Regexp options are also copied over if a new Regexp is created. I can
  #   def imagine things getting weird with some exotic regular expression
  #   or another, but this feature is really indented for very simple patterns,
  #   for which it should suffice.
  #   
  # @return [Boolean]
  #   `true` if `self` starts with *any* of the `prefixes`.
  # 
  def start_with? *prefixes
    unless prefixes.any? { |x| Regexp === x }
      return super( *prefixes )
    end
  
    prefixes.any? { |prefix|
      case prefix
      when Regexp
        unless prefix.source.start_with? '\A', '^'
          prefix = Regexp.new( "\\A#{ prefix.source }", prefix.options )
        end
        
        prefix =~ self
      else
        super( prefix )
      end
    }
  end
  
end # module String


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
