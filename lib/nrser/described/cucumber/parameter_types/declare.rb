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
  
  def declarations
    @declarations ||= {}
  end
  
  
  def declare name, **kwds
    name = name.to_sym unless name.is_a?( ::Symbol )
  
    if declarations.key? name
      raise NRSER::ConflictError.new \
        "Already declarations parameter type with name", name,
        existing_declaration: declarations[ name ],
        attempted_declaration: { name: name, **kwds }
    end
    
    declarations[ name ] = { name: name.to_s, **kwds }.freeze
  end
  
end # module Declare  


# /Namespace
# =======================================================================

end # module ParameterTypes
end # module Cucumber
end # module Described
end # module NRSER
