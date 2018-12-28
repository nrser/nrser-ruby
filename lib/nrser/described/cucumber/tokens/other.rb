# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

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

# 
class Other < Token
  
  quote nil
  pattern '.*'
  
  unquote_type  self
  to_value_type self
  
  def unquote
    self
  end
  
  def to_value
    self
  end
  
end # class Expr
  

# /Namespace
# =======================================================================

end # module Tokens
end # module Cucumber
end # module Described
end # module NRSER
