# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Extending {Callable}
require_relative './callable'

# Describes {Instance}
require_relative './instance'


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  RSpex
module  Described


# Definitions
# =======================================================================

class Response < Base

  # Config
  # ========================================================================
  
  subject_type NRSER::Meta::Params
  
  from callable: Callable, params: Params do |callable:, params:|
    params.call callable
  end
  
end # class Response


# /Namespace
# =======================================================================

end # module Described
end # module RSpex
end # module NRSER
