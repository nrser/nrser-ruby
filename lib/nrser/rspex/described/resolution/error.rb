# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# {Error} mixes in {NRSER::NicerError}
require 'nrser/errors/nicer_error'


# Namespace
# =======================================================================

module  NRSER
module  RSpex
module  Described
class   Resolution


# Definitions
# =======================================================================

# Raised when something goes irreparably wrong with {Resolution}s.
# 
# You should not need to rescue {Error} instances during normal use.
# 
# @note
#   Mixes in {NRSER::NicerError}.
# 
class Error < ::StandardError
  include NRSER::NicerError
end


# /Namespace
# =======================================================================

end # class Resolution
end # module Described
end # module RSpex
end # module NRSER
