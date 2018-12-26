# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

require 'set'

# Project / Package
# -----------------------------------------------------------------------

# Subtree
require_relative './parameter_types/consts'
require_relative './parameter_types/declare'
require_relative './parameter_types/descriptions'
require_relative './parameter_types/methods'
require_relative './parameter_types/quote'
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
  
  def self.declaration_modules
    constants.
      map { |name| const_get name }.
      select { |const|
        const.is_a?( ::Module ) && const.respond_to?( :declarations )
      }
  end
  
  
  def self.declarations
    declaration_modules.
      each_with_object( {} ) { |mod, result|
        mod.declarations.each { |name, values|
          if result.key? name
            raise NRSER::ConflictError.new \
              "Name", name, "in module", mod, "conflicts with previous",
              "declaration",
              previous_declaration: result[ name ]
          end
          
          result[ name ] = values
        }
      }
  end
  
  
  def self.register!
    declarations.each do |name, values|
      ParameterType **values
    end
  end
  
end # module ParameterTypes


# /Namespace
# =======================================================================

end # module Cucumber
end # module Described
end # module NRSER
