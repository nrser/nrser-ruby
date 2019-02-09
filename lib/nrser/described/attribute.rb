# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Extending {Object}
require_relative './object'


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
class Attribute < Object
  
  # Config
  # ========================================================================
  
  subject_type ::Object
  
  from object: Object, name: Meta::Names::Method do |object:, name:|
    object.public_send name
  end
  
end # class Attribute


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
