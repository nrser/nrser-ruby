# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Using {Meta::Args} realizations
require 'nrser/meta/args/array'
require 'nrser/meta/args/named'


# Using {Wrappers::Block}
require 'nrser/described/cucumber/wrappers'



# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  World


# Definitions
# =======================================================================

# World mixins to process values from Cucumber into {Meta::Args} and describe
# {Described::Arguments}.
# 
# Mixed in to the "step classes" where steps are executed via 
# {Cucumber::Glue::DSL::World}.
# 
module Arguments
  
  # Instance Methods
  # ========================================================================
  
  # Construct a {Meta::Args} from positional argument values, taking account
  # of the last value potentially being a {Wrappers::Block} that indicates it
  # is the block parameter.
  # 
  # @param [::Array<::Object>] values
  #   Parameter values.
  # 
  # @return [Meta::Args::Array]
  #   The new parameters object.
  # 
  def args_for_positional_values values
    # Handle the last entry being a `&...` expression, which is interpreted as 
    # the block parameter
    if values[ -1 ].is_a? Wrappers::Block
      args = values[ 0..-2 ]
      block = values[ -1 ]
    else
      args = values
      block = nil
    end
    
    Meta::Args::Array.new *args, &block
  end # args_for_positional_values
  
  
  # @todo Document args_for_table method.
  # 
  # @param [::Cucumber::MultilineArgument::DataTable] data_table
  #   Table of argument value sources.
  # 
  # @return [Meta::Args::Array]
  #   When `data_table` has a single column, which is interpreted as positional
  #   arguments.
  # 
  # @return [Meta::Args::Named]
  #   When `data_table` has two columns, which is interpreted as argument
  #   name and value rows.
  # 
  # @raise [RuntimeError<{data_table: ::Cucumber::MultilineArgument::DataTable}>]
  #   When `data_table` has more than two columns. `data_table` is included in 
  #   the error context.
  # 
  def args_for_data_table data_table
    case data_table.column_names.count
    when 1
      # The table is interpreted as a list of positional values, the last of 
      # which *may* be a block.
      args_for_positional_values \
        data_table.rows.map { |row|
          ParameterTypes::Values::VALUE.transform self,
                                                  [ row.first ],
                                                  pointer: false
        }
    
    when 2
      # The table is interpreted as argument name/value pairs, with the names
      # in {NRSER::Meta::Names} format (`arg`, `kwd:`, `&block`)
      data_table.rows.
        each_with_object(
          Meta::Args::Named.new
        ) do |(raw_name_string, raw_value_string), named_args|
          name = \
            ParameterTypes[ :param_name ].transform self,
                                                    [ raw_name_string ],
                                                    pointer: false
          
          value = \
            ParameterTypes[ :value ].transform  self,
                                                [ raw_value_string ],
                                                pointer: false
          
          named_args[ name ] = value
        end
      
    else
      # We don't handle any other dimensions
      raise RuntimeError.new \
        "Parameter table must be 1 or 2 columns, found ",
        data_table.column_names.count,
        data_table: data_table
      
    end # case table.column_names.count
  end # #args_for_table
  
end # module Arguments


# /Namespace
# =======================================================================

end # module World
end # module Cucumber
end # module Described
end # module NRSER
