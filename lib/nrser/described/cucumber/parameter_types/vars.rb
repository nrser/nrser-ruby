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
# used to create parameter types that match variable names.
# 
module Vars
  
  extend Declare
  extend Quote
  
  
  declare           :var_name,
    regexp:      [  backtick_quote( NRSER::Meta::Names::Var::Local ),
                    backtick_quote( NRSER::Meta::Names::Var::Instance ),
                    backtick_quote( NRSER::Meta::Names::Var::Global ), ],
    type:           NRSER::Meta::Names::Var,
    transformer:    ->( string ) {
      NRSER::Meta::Names::Var.from unquote( string )
    }
    
      
end # module Vars  


# /Namespace
# =======================================================================

end # module ParameterTypes
end # module Cucumber
end # module Described
end # module NRSER
