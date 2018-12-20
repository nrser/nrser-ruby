# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Describes {Callable}
require_relative './callable'

# Describes {Params}
require_relative './parameters'


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
  
  subject_type ::Object
  
  from callable: Callable, params: Parameters do |callable:, params:|
    params.call callable
  end
  
end # class Response


# /Namespace
# =======================================================================

end # module Described
end # module RSpex
end # module NRSER
