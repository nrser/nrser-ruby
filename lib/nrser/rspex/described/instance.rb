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

# Extending {Base}
require_relative './base'


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  RSpex
module  Described


# Definitions
# =======================================================================

# Abstract base class for all {NRSER::RSpex} description objects.
# 
# Description objects formalize and extend {RSpec}'s explicit subject 
# functionality.
# 
# @abstract
# 
class Instance < Base
  
  # Config
  # ========================================================================
  
  subject_type ::Object
  
  
  # Class Methods
  # ========================================================================
  
  
  # Attributes
  # ========================================================================
  
  
  # Construction
  # ========================================================================
  
  
  # Instance Methods
  # ========================================================================
  
  
end # class Callable


# /Namespace
# =======================================================================

end # module Described
end # module RSpex
end # module NRSER
