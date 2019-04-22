# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/meta/args/named'

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

module Arguments
  
  # Mixins
  # ==========================================================================
  
  extend Helpers
  
  
  # Steps
  # ==========================================================================
  
  THE_INLINE_PARAMS = \
    Step "the arguments {values}" \
    do |values|
      describe_positional_args values
    end

  
  THE_TABLE_PARAMS = \
    Step "the arguments:" do |table|
      case table.column_names.count
      when 1
        # The table is interpreted as a list of positional values, the last of 
        # which *may* be a block.
        describe_positional_args \
          table.rows.map { |row|
            ParameterTypes::Values::VALUE.transform self,
                                                    [ row.first ],
                                                    pointer: false
          }
      
      when 2
        # The table is interpreted as argument name/value pairs, with the names
        # in {NRSER::Meta::Names} format (`arg`, `kwd:`, `&block`)
        table.rows.each do |(raw_name_string, raw_value_string)|
          name = \
            ParameterTypes[ :param_name ].transform self,
                                                    [ raw_name_string ],
                                                    pointer: false
          
          value = \
            ParameterTypes[ :value ].transform  self,
                                                [ raw_value_string ],
                                                pointer: false
          
          describe_arg name, value
        end
        
      else
        # We don't handle any other dimensions
        raise NRSER::RuntimeError.new \
          "Parameter table must be 1 or 2 columns, found ",
          table.column_names.count,
          table: table
        
      end # case table.column_names.count
    end # Step
  


  Step "the {param_name} argument is {value}" do |param_name, value|
    describe_arg param_name, value
  end

  

  Step "the block argument is {value}" do |value|
    if described.is_a? NRSER::Described::Arguments
      described.block = value
    else
      describe :arguments,
        subject: NRSER::Meta::Args::Named.new( block: value )
    end
  end
  
end # module Arguments

# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
