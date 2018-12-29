# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

require 'set'

# Deps
# -----------------------------------------------------------------------

# Need {::Cucumber::Glue::DSL.define_parameter_type} to register
require 'cucumber/glue/dsl'

# Project / Package
# -----------------------------------------------------------------------

# Subtree
require_relative './parameter_types/consts'
require_relative './parameter_types/declare'
require_relative './parameter_types/descriptions'
require_relative './parameter_types/methods'
require_relative './parameter_types/params'
require_relative './parameter_types/values'
require_relative './parameter_types/vars'


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber


# Definitions
# =======================================================================

# Support for the {Cucumber::Glue::DLS::ParameterType} instances used in 
# the description {Steps}.
# 
module ParameterTypes  
  
  def self.definition_modules
    constants.
      map { |name| const_get name }.
      select { |const|
        const.is_a?( ::Module ) && const.respond_to?( :parameter_types )
      }
  end
  
  
  def self.parameter_types
    definition_modules.
      each_with_object( {} ) { |mod, result|
        mod.parameter_types.each { |name, parameter_type|
          if result.key? name
            raise NRSER::ConflictError.new \
              "Name", name, "in module", mod, "conflicts with previous",
              "definition",
              previous_parameter_type: result[ name ],
              conflicting_parameter_type: parameter_type
          end
          
          result[ name ] = parameter_type
        }
      }
  end
  
  
  def self.find! name
    name = name.to_sym unless name.is_a?( ::Symbol )
    
    definition_modules.each do |mod|
      return mod.parameter_types[ name ] if mod.parameter_types.key?( name )
    end
    
    raise NRSER::KeyError.new \
      "Parameter type", name, "not found"
  end
  
  singleton_class.send :alias_method, :[], :find!
  
  
  def self.register!
    parameter_types.each do |name, parameter_type|
      ::Cucumber::Glue::Dsl.define_parameter_type parameter_type
    end
  end
  
end # module ParameterTypes


# /Namespace
# =======================================================================

end # module Cucumber
end # module Described
end # module NRSER
