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
module  Described


# Definitions
# =======================================================================

# @todo doc me!
# 
class InstanceMethod < Callable
  
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
