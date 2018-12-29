# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Need {::Cucumber::Glue::DSL.register_rb_step_definition} to register
require 'cucumber/glue/dsl'

# Project / Package
# -----------------------------------------------------------------------


# Refinements
# =======================================================================


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  Steps


# Definitions
# =======================================================================

module Helpers
  
  def Step *args, &block
    ::Cucumber::Glue::Dsl.
      instance_method( :register_rb_step_definition ).
      bind( self ).call *args, &block
  end
  
end # module Helpers

# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
