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
  
  
  # Constants
  # ========================================================================
  
  # DOUBLE_QUOTED_STRING_REGEXP = re.new /"(?:[^"\\]|\\.)*"/
  # SINGLE_QUOTED_STRING_REGEXP = re.new /'(?:[^'\\]|\\.)*'/
  
  # STRING_REGEXP = \
  #   re.or DOUBLE_QUOTED_STRING_REGEXP, SINGLE_QUOTED_STRING_REGEXP
  
  # INTEGER_REGEXPS = [ /-?\d+/, /\d+/ ].map { |r| re.new r }
  
  # FLOAT_REGEXP = re.new /-?\d*\.\d+/
  
  # EXPR_REGEXP = backtick_quote '[^\`]*'
  
  
  # # The list of {::Regexp} for the different things that can be a value.
  # # 
  # # Though we can (and will!) combine them using {NRSER::Regexps::Composed.or},
  # # inspection of {::Cucumber::CucumberExpressions::ParameterType} reveals not
  # # only that it accepts a list of possible regular expressions, but it simply
  # # extracts the source strings from them, so this should be more efficient and
  # # be much easier to deal with in debugging.
  # # 
  # # @return [::Array<::Regexp>]
  # # 
  # VALUE_REGEXPS = [ STRING_REGEXP,
  #                   *INTEGER_REGEXPS,
  #                   FLOAT_REGEXP,
  #                   EXPR_REGEXP,
  #                   *Consts.declarations[ :const ][ :regexp ],
  #                   *Methods.declarations[ :method ][ :regexp ] ]
  
  
  # # {VALUE_REGEXPS} combined into a single expression using 
  # # {NRSER::Regexps::Composed.or}, which we will need to form an expression to
  # # match comma-separated list of them (for matching parameter lists).
  # # 
  # # @note
  # #   This is a *terribly* long and complicated regular expression (over 1400
  # #   characters at the moment).
  # # 
  # # @return [NRSER::Regexps::Composed]
  # # 
  # VALUE_REGEXP = re.or *VALUE_REGEXPS
  
  
  # Declarations
  # ============================================================================
  
  def self.block_expr? string
    string = backtick_unquote( string ) if backtick_quoted?( string )
    string.start_with? '&'
  end
  
  def_parameter_type \
    name:           :raw_expr,
    patterns:       Tokens::Expr
  
  def_parameter_type \
    name:           :expr_src,
    patterns:       Tokens::Expr,
    transformer:    :unquote
  
  def_parameter_type \
    name:           :expr,
    patterns:       Tokens::Expr,
    transformer:    :to_value
  
  
  def_parameter_type \
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
  
  
  def_parameter_type \
    name:           :params,
                    # Good lord... this {::Regexp} source is gonna be a messs...
    patterns:       re.join(
                        parameter_types[ :value ],
                        '(?:,\s*', parameter_types[ :value ], ')*'
                    ),
    type:           ::Array,
    transformer:    ->( *tokens ) {
      binding.pry
      string.scan VALUE_REGEXP
    }
  
  
  
  
end # module Values  


# /Namespace
# =======================================================================

end # module ParameterTypes
end # module Cucumber
end # module Described
end # module NRSER
