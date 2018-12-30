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
module  Described


# Definitions
# =======================================================================

class Error < Base

  # Config
  # ========================================================================
  
  subject_type ::Exception
  
  from callable: Callable, params: Parameters do |callable:, params:|
    begin
      response = params.call callable
    rescue Exception => error
      error
    else
      raise NRSER::RuntimeError.new \
        "Expected", Callable, "to raise, but responded",
        response: response,
        callable: callable,
        parameters: parameters
    end
  end
  
end # class Response


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
