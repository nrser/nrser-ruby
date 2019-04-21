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



# Namespace
# =======================================================================

module  NRSER
module  Described


# Definitions
# =======================================================================

# Describes arguments to a method call, including {Instance} construction.
# 
class Arguments < Base
  
  # Config
  # ========================================================================
  
  subject_type NRSER::Meta::Params
  
  
  # Instance Methods
  # ========================================================================
  
  def []= name, value
    subject[ name ] = value
  end
  
end # class Arguments


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
