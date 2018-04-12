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

require_relative './nicer_error'


# Declarations
# =======================================================================


# Definitions
# =======================================================================


# Extension of {::ArgumentError} that includes {NRSER::NicerError} and
# supports optional
# 
class NRSER::ArgumentError < ::ArgumentError
  
  include NRSER::NicerError
  
  
  # Instance Methods
  # ========================================================================
  
  # def default_message
  #   ["Expected", name, ""]
  # end
  
end # class NRSER::ArgumentError
