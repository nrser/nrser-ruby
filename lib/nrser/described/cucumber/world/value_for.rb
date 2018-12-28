# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/described'


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  World


# Definitions
# =======================================================================

# @todo doc me!
module ValueFor
  
  # Instance Methods
  # ========================================================================
  
  def value_for value_string, accept_block: false
    # if accept_block && ParameterTypes::Values.block_expr?( value_string )
    #   eval "->( &block ) { block }.call( #{ value_string } )"
    # else
    #   instance_exec \
    #     value_string,
    #     &ParameterTypes::Values.declarations[ :value ][ :transformer ]
    # end
    
    ParameterTypes::Values[ :value ].transform self, [ value_string ]
  
    # if expr? string
    #   source_string = backtick_unquote string
      
    #   if accept_unary_ampersand && unary_ampersand_expr?( source_string )
    #     eval "->( &block ) { block }.call( #{ source_string } )"
    #   else
    #     eval source_string
    #   end
    # else
    #   raise NRSER::NotImplementedError.new \
    #     "TODO can only handle expr strings so far, found", string.inspect,
    #     "(which is a", string.class, ")"
    # end
  end
  
end # module ValueFor


# /Namespace
# =======================================================================

end # module World
end # module Cucumber
end # module Described
end # module NRSER
