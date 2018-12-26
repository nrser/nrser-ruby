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
module Methods

  extend Declare
  extend Quote
  
  declare           :method_name,
    regexp:      [  backtick_quote( Names::Method::Bare ),
                    curly_quote( Names::Method::Singleton ),
                    curly_quote( Names::Method::Instance ),
                    curly_quote( Names::Method::Explicit::Singleton ),
                    curly_quote( Names::Method::Explicit::Instance ) ],
    type:           NRSER::Meta::Names::Method,
    transformer:    ->( string ) {
      NRSER::Meta::Names::Method.from unquote( string )
    }
    
  
  declare           :singleton_method_name,
    regexp:      [  backtick_quote( Names::Method::Bare ),
                    curly_quote( Names::Method::Singleton ),
                    curly_quote( Names::Method::Explicit::Singleton ) ],
    type:           NRSER::Meta::Names::Method,
    transformer:    ->( string ) {
      # TODO  Should this convert {Bare} to {Singleton}?
      NRSER::Meta::Names::Method.from unquote( string )
    }
    
    
  declare           :instance_method_name,
    regexp:      [  backtick_quote( Names::Method::Bare ),
                    curly_quote( Names::Method::Instance ),
                    curly_quote( Names::Method::Explicit::Instance ) ],
    type:           NRSER::Meta::Names::Method,
    transformer:    ->( string ) {
      # TODO  Should this convert {Bare} to {Instance}?
      NRSER::Meta::Names::Method.from unquote( string )
    }
  
  
  declare           :method,
    regexp:         declarations[ :method_name ][ :regexp ],
    type:           ::Object, # Really {::Method} or {::UnboundMethod}
    transformer:    ->( string ) {
      resolve_method NRSER::Meta::Names::Method.from( unquote( string ) )
    }
  
  
  declare           :singleton_method,
    regexp:         declarations[ :singleton_method_name ][ :regexp ],
    type:           ::Method,
    transformer:    ->( string ) {
      resolve_singleton_method \
        NRSER::Meta::Names::Method.from( unquote( string ) )
    }
  
  
  declare           :instance_method,
    regexp:         declarations[ :instance_method_name ][ :regexp ],
    type:           ::UnboundMethod,
    transformer:    ->( string ) {
      resolve_instance_method \
        NRSER::Meta::Names::Method.from( unquote( string ) )
    }
  
    
end # module Methods  


# /Namespace
# =======================================================================

end # module ParameterTypes
end # module Cucumber
end # module Described
end # module NRSER
