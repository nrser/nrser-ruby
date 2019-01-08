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
  
  def register_rb_step_definition_method
    @register_rb_step_definition_method ||= \
      ::Cucumber::Glue::Dsl.
        instance_method( :register_rb_step_definition ).
        bind( self )
  end
  
  
  def Step *args, &block
    register_rb_step_definition_method.call *args do |*yielded|
      begin
        instance_exec *yielded, &block
      rescue SystemExit
        raise
      rescue Exception => error
        binding.pry if ENV[ 'NRSER_PRY' ].n_x.truthy?
        raise
      end
    end
  end
  
end # module Helpers

# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
