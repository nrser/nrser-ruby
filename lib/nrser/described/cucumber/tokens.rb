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
require_relative './tokens/const'
require_relative './tokens/expr'
require_relative './tokens/literal'
require_relative './tokens/method'
require_relative './tokens/other'
require_relative './tokens/param'
require_relative './tokens/var'


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
end # module Tokens


# /Namespace
# =======================================================================

end # module Cucumber
end # module Described
end # module NRSER
