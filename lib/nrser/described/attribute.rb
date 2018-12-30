# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

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
class Attribute < Base
  
  # Config
  # ========================================================================
  
  subject_type ::Object
  
  from object: Object, :@name => self.Names::Method do |object:, name:|
    object.public_send name
  end
  
end # class Attribute


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
