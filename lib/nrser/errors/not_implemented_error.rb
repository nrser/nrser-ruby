# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require_relative './nicer_error'


# Namespace
# =======================================================================

module  NRSER


# Definitions
# =======================================================================

class NotImplementedError < ::NotImplementedError
  include NicerError
end


# /Namespace
# =======================================================================

end # module NRSER
