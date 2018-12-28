# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------

require_relative './parameter_type'

# Refinements
# =======================================================================

require 'nrser/refinements/regexps'
using NRSER::Regexps


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  ParameterTypes


# Definitions
# =======================================================================

# Mixin extended in to modules that declare parameter types, providing the
# necessary methods.
#
module Declare
  
  def parameter_types
    @parameter_types ||= {}
  end
  
  
  def def_parameter_type name:, **kwds
    name = name.to_sym unless name.is_a?( ::Symbol )
  
    if parameter_types.key? name
      raise NRSER::ConflictError.new \
        "Already defined parameter type with name", name,
        existing_parameter_type: parameter_types[ name ],
        attempted_definition: { name: name, **kwds }
    end
    
    ParameterType.new( name: name, **kwds ).tap { |parameter_type|
      parameter_types[ name ] = parameter_type
      ::Cucumber::Glue::Dsl.define_parameter_type parameter_type
    }
  end
  
end # module Declare  


# /Namespace
# =======================================================================

end # module ParameterTypes
end # module Cucumber
end # module Described
end # module NRSER
