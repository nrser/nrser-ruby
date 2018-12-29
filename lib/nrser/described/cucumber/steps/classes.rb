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

module Classes
  
  # Mixins
  # ==========================================================================
  
  extend Helpers
  
  
  # Steps
  # ==========================================================================
  
  THE_CLASS = \
    Step "the class {class}" do |cls|
      describe :class, subject: cls
    end
  
    
  A_CLASS = \
    Step "a class:" do |string|
      scope.class_eval string
      class_name = re.
        join( 'class (', NRSER::Meta::Names::Const.pattern, ')' ).
        match( string )[ 1 ]
      describe_class class_name
    end
  
end # module Classes

# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
