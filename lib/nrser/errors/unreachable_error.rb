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

# Raised in places where execution should *never* reach.
# 
class UnreachableError < ::RuntimeError
  include NRSER::NicerError

  # The default message 
  # 
  # @return [String]
  # 
  def default_message
    "An expression that should be unreachable has been executed"
  end

end # class UnreachableError


# /Namespace
# ========================================================================

end # module NRSER
