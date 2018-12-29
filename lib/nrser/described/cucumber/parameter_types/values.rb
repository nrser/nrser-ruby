# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Need to deal with tokens
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
# used to create parameter types that match general values.
# 
module Values
  
  # Mixins
  # ========================================================================
  
  extend Declare
  extend World::Quote
  
  
  # Parameter Types
  # ========================================================================  
  
  RAW_EXPR = def_parameter_type \
    name:           :raw_expr,
    patterns:       Tokens::Expr
  
  
  EXPR_SRC = def_parameter_type \
    name:           :expr_src,
    patterns:       Tokens::Expr,
    transformer:    :unquote
  
  
  EXPR = def_parameter_type \
    name:           :expr,
    patterns:       Tokens::Expr,
    transformer:    :to_value
  
  
  VALUE = def_parameter_type \
    name:         :value,
    patterns:     [ Tokens::Expr,
                    Tokens::Literal::String::SingleQuoted,
                    Tokens::Literal::String::DoubleQuoted,
                    Tokens::Literal::Integer,
                    Tokens::Literal::Float,
                    Tokens::Const,
                    Tokens::Method::Singleton,
                    Tokens::Method::Instance,
                    Tokens::Method::Explicit::Singleton,
                    Tokens::Method::Explicit::Instance, ],
    type:           ::Object,
    transformer:    :to_value
  
  
  # A comma-separated list of {VALUE}.
  # 
  # @return [ParameterType]
  # 
  VALUES = def_parameter_type \
    name:           :values,
                    # Good lord... this {::Regexp} source is gonna be a messs...
    patterns:       re.join( VALUE, '(?:,\s*', VALUE, ')*' ),
    type:           ::Array,
    transformer:    ->( full_string ) {
      # Need to use full path to the constant here since we're evaluated in
      # the scenario instance
      value_parameter_type = \
        NRSER::Described::Cucumber::ParameterTypes::Values::VALUE
      
      full_string.
        scan( value_parameter_type.to_re ).
        map { |raw_value_string|
          value_parameter_type.transform self, [ raw_value_string ]
        }
    }
  
end # module Values  


# /Namespace
# =======================================================================

end # module ParameterTypes
end # module Cucumber
end # module Described
end # module NRSER
