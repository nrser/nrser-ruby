# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Need to extend in the {Declare} mixin to get `.declare`, etc.
require_relative './declare'

# Need to extend in the {Quote} mixin
require_relative './quote'

# Using the regular expressions and transformers for constants to match and
# transform them as values
require_relative './consts'

# Using the regular expressions and transformers for methods to match and
# transform them as values
require_relative './methods'


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
  extend Quote
  
  
  # Constants
  # ========================================================================
  
  EXPR_REGEXP = backtick_quote '[^\`]*'
  
  DOUBLE_QUOTED_STRING_REGEXP = /"(?:[^"\\]|\\.)*"/
  SINGLE_QUOTED_STRING_REGEXP = /'(?:[^'\\]|\\.)*'/
  
  STRING_REGEXP = \
    re.or DOUBLE_QUOTED_STRING_REGEXP, SINGLE_QUOTED_STRING_REGEXP
  
  INTEGER_REGEXPS = [ /-?\d+/, /\d+/ ]
  
  FLOAT_REGEXP = /-?\d*\.\d+/
  
  
  # Declarations
  # ============================================================================
  
  declare           :expr,
    regexp:         EXPR_REGEXP,
    type:           ::Object,
    transformer:    ->( string ) {
      eval backtick_unquote( string )
    }     
  
  
  declare           :value,
    regexp:       [ STRING_REGEXP,
                    *INTEGER_REGEXPS,
                    FLOAT_REGEXP,
                    *declarations[ :expr ][ :regexp ],
                    *Consts.declarations[ :const ][ :regexp ],
                    *Methods.declarations[ :method ][ :regexp ], ],
    type:           ::Object,
    transformer:    ->( string ) {
      case string
      when STRING_REGEXP
        eval string
        
      when *INTEGER_REGEXPS
        string.to_i
        
      when FLOAT_REGEXP
        string.to_f
        
      when *declarations[ :expr ][ :regexp ]
        instance_eval string, &declarations[ :expr ][ :transformer ]
        
      when *Consts.declarations[ :const ][ :regexp ]
        instance_eval string, &Consts.declarations[ :const ][ :transformer ]
      
      when *Methods.declated[ :method ][ :regexp ]
        instance_eval string, &Methods.declarations[ :method ][ :transformer ]
        
      else
        raise NRSER::UnreachableError
      end
    }
  
end # module Values  


# /Namespace
# =======================================================================

end # module ParameterTypes
end # module Cucumber
end # module Described
end # module NRSER
