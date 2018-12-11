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
class Callable < Base
  
  # Config
  # ========================================================================
  
  type t.responds_to( :call )
  
  
  # Class Methods
  # ========================================================================
  
  
  # Attributes
  # ========================================================================
  
  
  # Construction
  # ========================================================================
  
  # Instantiate a new `Base`.
  def initialize
    
  end # #initialize
  
  
  # Instance Methods
  # ========================================================================
  
  
end # class Callable


# /Namespace
# =======================================================================

end # module Described
end # module RSpex
end # module NRSER
