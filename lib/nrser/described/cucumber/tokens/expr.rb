# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/described/cucumber/wrappers'

# Extends {Token}
require_relative './token'


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

class Expr < Token
  
  quote :backtick
  pattern backtick_quote( '[^\`]*' )
  
  unquote_type Wrappers::Strings::Src
  to_value_type ::Object
  
  def unquote
    Wrappers::Strings::Src.new self[ 1..-2 ]
  end
  
  # @return (see Wrappers::Strings::Src#to_value)
  # 
  def to_value self_obj
    unquote.to_value self_obj
  end
  
end # class Expr
  

# /Namespace
# =======================================================================

end # module Tokens
end # module Cucumber
end # module Described
end # module NRSER
