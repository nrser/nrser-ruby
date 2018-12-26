# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Using names of Ruby things
require 'nrser/meta/names'

# Need to extend in the {Quote} mixin
require_relative './quote'

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
  extend Quote
  
  
  declare           :param_name,
    regexp:      [  backtick_quote( NRSER::Meta::Names::Param::Positional ),
                    backtick_quote( NRSER::Meta::Names::Param::Keyword ),
                    backtick_quote( NRSER::Meta::Names::Param::Block ),
                    backtick_quote( NRSER::Meta::Names::Param::Rest ),
                    backtick_quote( NRSER::Meta::Names::Param::KeyRest ), ],
    type:           NRSER::Meta::Names::Param,
    transformer:    ->( string ) {
      NRSER::Meta::Names::Param.from unquote( string )
    }
    
      
end # module Params  


# /Namespace
# =======================================================================

end # module ParameterTypes
end # module Cucumber
end # module Described
end # module NRSER
