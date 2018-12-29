# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Extending in {Helpers}
require_relative './helpers'


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  Steps


# Definitions
# =======================================================================

module Parameters
  
  # Mixins
  # ==========================================================================
  
  extend Helpers
  
  
  # Steps
  # ==========================================================================
  
  THE_INLINE_PARAMETERS = \
    Step "the parameters {params}" \
    do |value_strings|
      describe_positional_params value_strings
    end

  
  THE_TABLE_PARAMETERS = \
    Step "the parameters:" do |table|
      case table.column_names.count
      when 1
        # The table is interpreted as a list of positional values, the last of 
        # which *may* be a block.
        describe_positional_params table.rows.map( &:first )
      when 2
        # The table is interpreted as parameter name/value pairs, with the names
        # in {NRSER::Meta::Names} format (`arg`, `kwd:`, `&block`)
        table.rows.each do |(name, string)|
          name = Names::Param.from name
          describe_param name,
            value_for( string, accept_block: name.block? )
        end
      else
        # We don't handle any other dimensions
        raise NRSER::RuntimeError.new \
          "Parameter table must be 1 or 2 columns, found ",
          table.column_names.count,
          table: table
      end
    end

  PARAMETER_NAME_IS = \
    Step "the {param_name} parameter is {raw_expr}" do |param_name, string|
      describe_param \
        param_name,
        value_for( string, accept_block: param_name.block? )
    end

  
  BLOCK_PARAMETER_IS = \
    Step "the block parameter is {raw_expr}" do |string|
      if described.is_a? NRSER::Described::Parameters
        described.block = value_for string, accept_block: true
      else
        describe :parameters,
          subject: NRSER::Meta::Params.new(
            block: value_for( string, accept_block: true )
          )
      end
    end
  
end # module Parameters

# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
