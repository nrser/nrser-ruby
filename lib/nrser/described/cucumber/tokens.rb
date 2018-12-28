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

# Subtree
require_relative './tokens/expr'
require_relative './tokens/literal'
require_relative './tokens/name'
require_relative './tokens/other'
require_relative './tokens/token'


# Refinements
# =======================================================================

require 'nrser/refinements/regexps'
using NRSER::Regexps


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber


# Definitions
# =======================================================================

# Various subclasses of {NRSER::Strings::Patterned} used to recognize and
# process classes of string input from Cucumber feature files.
# 
module Tokens
  
  # class Value < Token
  #   pattern \
  #     re.or(
  #       Expr::Quoted,
  #       Literal::String::SingleQuoted,
  #       Literal::String::DoubleQuoted,
  #       Literal::Integer,
  #       Literal::Float,
  #       Link::Const,
  #       Link::Method::Singleton,
  #       Link::Method::Instance,
  #       Link::Method::Explicit::Singleton,
  #       Link::Method::Explicit::Instance,
  #       full: true
  #     )
  # end # Value
  
end # module Tokens

# /Namespace
# =======================================================================

end # module Cucumber
end # module Described
end # module NRSER
