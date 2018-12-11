# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require_relative './nicer_error'


# Namespace
# ========================================================================

module  NRSER


# Definitions
# =======================================================================

# Raised when something is not found.
# 
class NotFoundError < ::StandardError
  include NicerError
end # class NotFoundError


# /Namespace
# ========================================================================

end # module NRSER
