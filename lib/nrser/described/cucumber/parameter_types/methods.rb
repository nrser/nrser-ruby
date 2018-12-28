# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Using names of Ruby things
require 'nrser/meta/names'

# Using the parameter tokens
require 'nrser/described/cucumber/tokens'

# Need to extend in the {Quote} mixin
require 'nrser/described/cucumber/world/quote'

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
module Methods

  extend Declare
  extend World::Quote

  
  def_parameter_type  \
    name:           :method_name,
    patterns:     [ Tokens::Method::Bare,
                    Tokens::Method::Singleton,
                    Tokens::Method::Instance,
                    Tokens::Method::Explicit::Singleton,
                    Tokens::Method::Explicit::Instance, ],
    type:           NRSER::Meta::Names::Method,
    transformer:    :unquote
    
  
  def_parameter_type \
    name:           :singleton_method_name,
    patterns:     [ Tokens::Method::Bare,
                    Tokens::Method::Singleton,
                    Tokens::Method::Explicit::Singleton, ],
    type:           NRSER::Meta::Names::Method,
    transformer:    :unquote
    
    
  def_parameter_type \
    name:           :instance_method_name,
    patterns:     [ Tokens::Method::Bare,
                    Tokens::Method::Instance,
                    Tokens::Method::Explicit::Instance, ],
    type:           NRSER::Meta::Names::Method,
    transformer:    :unquote
  
  
  def_parameter_type \
    name:           :method,
    patterns:       parameter_types[ :method_name ],
    type:           ::Object, # Really {::Method} or {::UnboundMethod}
    transformer:    ->( method_token ) { resolve_method method_token.unquote }
  
  
  def_parameter_type \
    name:           :singleton_method,
    patterns:       parameter_types[ :singleton_method_name ],
    type:           ::Method,
    transformer:    ->( method_token ) {
      resolve_singleton_method method_token.unquote
    }
  
  
  def_parameter_type \
    name:           :instance_method,
    patterns:       parameter_types[ :instance_method_name ],
    type:           ::UnboundMethod,
    transformer:    ->( method_token ) {
      resolve_instance_method method_token.unquote
    }
  
    
end # module Methods  


# /Namespace
# =======================================================================

end # module ParameterTypes
end # module Cucumber
end # module Described
end # module NRSER
