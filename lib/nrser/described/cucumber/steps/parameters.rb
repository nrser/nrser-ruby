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
  
  THE_INLINE_PARAMS = \
    Step "the parameters {values}" \
    do |values|
      describe_positional_params values
    end

  
  THE_TABLE_PARAMS = \
    Step "the parameters:" do |table|
      case table.column_names.count
      when 1
        # The table is interpreted as a list of positional values, the last of 
        # which *may* be a block.
        describe_positional_params \
          table.rows.map { |row|
            ParameterTypes::Values::VALUE.transform self, [ row.first ]
          }
      
      when 2
        # The table is interpreted as parameter name/value pairs, with the names
        # in {NRSER::Meta::Names} format (`arg`, `kwd:`, `&block`)
        table.rows.each do |(raw_name_string, raw_value_string)|
          name = \
            ParameterTypes[ :param_name ].transform self, [ raw_name_string ]
          
          value = \
            ParameterTypes[ :value ].transform self, [ raw_value_string ]
          
          describe_param name, value
        end
        
      else
        # We don't handle any other dimensions
        raise NRSER::RuntimeError.new \
          "Parameter table must be 1 or 2 columns, found ",
          table.column_names.count,
          table: table
        
      end # case table.column_names.count
    end # Step
  

  PARAM_NAME_IS = \
    Step "the {param_name} parameter is {value}" do |param_name, value|
      describe_param param_name, value
    end

  
  BLOCK_PARAM_IS = \
    Step "the block parameter is {value}" do |value|
      if described.is_a? NRSER::Described::Parameters
        described.block = value
      else
        describe :parameters,
          subject: NRSER::Meta::Params::Named.new( block: value )
      end
    end
  
end # module Parameters

# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
