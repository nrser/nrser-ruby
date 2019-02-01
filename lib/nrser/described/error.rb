# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Describes {Response}, {Instance}
require_relative './response'
require_relative './instance'


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
  
    
  # TODO  
  # from From::ErrorOf[ Response ]
  from error: From::ErrorOf[ Response ] do |error:|
    error
  end
  
  # TODO
  # from From::ErrorOf[ Instance ]
  from error: From::ErrorOf[ Instance ] do |error:|
    error
  end
  
end # class Response


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
