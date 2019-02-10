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

# Extending {Object}
require_relative './base'


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  Described


# Definitions
# =======================================================================

# @todo doc me
# 
class Callable < Object
  
  # Config
  # ========================================================================
  
  subject_type t.RespondTo( :call )
  
end # class Callable


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
