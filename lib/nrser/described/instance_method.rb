# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Extending {Object}
require_relative './object'

# Describes {Module}
require_relative './module'


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
class InstanceMethod < Object
  
  # Config
  # ========================================================================
  
  subject_type ::UnboundMethod
  
  subject_from module_: Module, name: Meta::Names::Method do |module_:, name:|
    module_.instance_method name
  end
  
end # class InstanceMethod


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
