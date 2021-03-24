# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require_relative './base'


# Refinements
# ============================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  StepComponent


# Definitions
# =======================================================================

# A Cucumber step component that is composed of other step components.
# 
class Composite < Base
end # class Composite


# /Namespace
# =======================================================================

end # module StepComponent
end # module Cucumber
end # module Described
end # module NRSER
