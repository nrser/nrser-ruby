# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Using {NRSER::Meta::Names::Const.pattern}
require 'nrser/meta/names'

# Extending in {Helpers}
require_relative './helpers'


# Refinements
# =======================================================================

require 'nrser/refinements/regexps'
using NRSER::Regexps


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  Steps


# Definitions
# =======================================================================

module Modules
  
  # Mixins
  # ==========================================================================
  
  extend Helpers
  
  
  # Steps
  # ==========================================================================
  
  A_MODULE = \
    Step "a module:" do |source|
      scope.class_eval source
      module_name = NRSER::Regexps::Composed.
        join( 'module (', NRSER::Meta::Names::Const.pattern, ')' ).
        match( source )[ 1 ]
      describe_module module_name
    end
  
end # module Modules

# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
