# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require_relative './nicer_error'


# Definitions
# =======================================================================

# General error for raising when something conflicts with something else -
# it's not the type or an argument, but something about the data or
# configuration just isn't ok.
# 
module NRSER
class ConflictError < ::StandardError
  include NRSER::NicerError
end; end # class NRSER::ConflictError
