# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------

# {Token} extends {NRSER::Strings::Patterned}
require 'nrser/strings/patterned'

# Mixin in quoting and unquoting methods
require 'nrser/described/cucumber/world/quote'


# Refinements
# =======================================================================

require 'nrser/refinements/regexps'
using NRSER::Regexps


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  Tokens


# Definitions
# =======================================================================

# Abstract base class for all parameter type tokens.
# 
# @abstract
# 
class Token < NRSER::Strings::Patterned
  extend World::Quote
  include World::Quote
  
  include NRSER::Meta::ClassAttrs
  
  class_attr      :quote,
    write_once:   true,
    default:      nil
  
  class_attr      :unquote_type,
    write_once:   true
  
  class_attr      :to_value_type,
    write_once:   true
  
  unquote_type ::String
  
  def unquote
    case self.class.quote
    when nil
      self
    when :backtick
      backtick_unquote self
    when :curly
      curly_unquote self
    when :single
      single_unquote self
    when :double
      double_unquote self
    else
      raise "bad class.quote: #{ self.class.quote.inspect }"
    end
  end
  
  def to_value self_obj
    raise NRSER::AbstractMethodError.new self, __method__
  end
end # class Token
  

# /Namespace
# =======================================================================

end # module Tokens
end # module Cucumber
end # module Described
end # module NRSER
