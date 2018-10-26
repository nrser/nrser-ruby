# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/sys/env'


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# =======================================================================

module String
  
  # Instance Methods
  # ========================================================================

  # @!group System Environment Instance Methods
  # --------------------------------------------------------------------------
  
  # Attempt to convert `self` into an ENV var name.
  # 
  # @see NRSER::Sys::Env.varize
  # 
  # @return (see NRSER::Sys::Env.varize)
  # 
  def env_varize
    NRSER::Sys::Env.varize self
  end

  # @!endgroup System Environment Instance Methods # *************************

end # module String


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
