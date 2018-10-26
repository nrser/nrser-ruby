# encoding: UTF-8
# frozen_string_literal: true

##############################################################################
# {String} Extensions for Working with System Environment Variables
# ============================================================================
# 
# Adds methods from `//lib/nrser/functions/text` to {String} targeting itself.
# 
##############################################################################


# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/sys/env'


# Definitions
# =======================================================================

class String
  
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

end
