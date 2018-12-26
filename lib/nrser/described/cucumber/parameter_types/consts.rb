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
# used to create parameter types that match constant names.
# 
module Consts
  
  extend Declare
  extend Quote
  
  
  declare           :const_name,
    regexp:         curly_quote( NRSER::Meta::Names::Const ),
    type:           NRSER::Meta::Names::Const,
    transformer:    ->( string ) {
      NRSER::Meta::Names::Const.new curly_unquote( string )
    }
  
  
  declare           :const,
    regexp:         declarations[ :const_name ][ :regexp ],
    type:           NRSER::Meta::Names::Const,
    transformer:    ->( string ) {
      resolve_const NRSER::Meta::Names::Const.new( curly_unquote( string ) )
    }
  
  
  declare           :module,
    regexp:         declarations[ :const_name ][ :regexp ],
    type:           NRSER::Meta::Names::Const,
    transformer:    ->( string ) {
      resolve_module NRSER::Meta::Names::Const.new( curly_unquote( string ) )
    }
  
  
  declare           :class,
    regexp:         declarations[ :const_name ][ :regexp ],
    type:           NRSER::Meta::Names::Const,
    transformer:    ->( string ) {
      resolve_class NRSER::Meta::Names::Const.new( curly_unquote( string ) )
    }
  
  
end # module Consts  


# /Namespace
# =======================================================================

end # module ParameterTypes
end # module Cucumber
end # module Described
end # module NRSER
