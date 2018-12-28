# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Using names of Ruby things
require 'nrser/meta/names'

# Need to extend in the {Quote} mixin
require 'nrser/described/cucumber/world/quote'

# Need to deal with tokens
require 'nrser/described/cucumber/tokens'

# Need to extend in the {Declare} mixin to get `.declare`, etc.
require_relative './declare'


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

# Declarations of {Cucumber::Glue::DLS::ParameterType} construction values
# used to create parameter types that match methods.
# 
module Params
  
  extend Declare
  extend World::Quote
  
  
  def_parameter_type \
    name:          :param_name,
    patterns:     [ Tokens::Param::Positional,
                    Tokens::Param::Keyword,
                    Tokens::Param::Block,
                    Tokens::Param::Rest,
                    Tokens::Param::KeyRest, ],
    type:           NRSER::Meta::Names::Param,
    transformer:    :unquote
    
      
end # module Params  


# /Namespace
# =======================================================================

end # module ParameterTypes
end # module Cucumber
end # module Described
end # module NRSER
