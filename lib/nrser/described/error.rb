# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Describes {Response}
require_relative './response'


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  Described


# Definitions
# =======================================================================

class Error < Base

  # Config
  # ========================================================================
  
  subject_type ::Exception
  
  from error_: Response do |error_:|
    error_
  end
  
end # class Response


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
