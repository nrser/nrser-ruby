# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Subjects are {NRSER::Meta::Params}
require 'nrser/meta/params'

# Extending {Base}
require_relative './base'


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

# @todo doc me!
# 
class Parameters < Base
  
  # Config
  # ========================================================================
  
  subject_type NRSER::Meta::Params

  
  # Construction
  # ========================================================================
  
  # def initialize parent: nil, values: {}
  #   super( parent: parent, subject: NRSER::Meta::Params.new( values ) )
  # end
  
  
  # Instance Methods
  # ========================================================================
  
  def []= name, value
    subject[ name ] = value
  end
  
end # class Callable


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
