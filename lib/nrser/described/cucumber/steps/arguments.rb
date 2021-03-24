# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Using {Meta::Args} realizations
require 'nrser/meta/args/array'
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
  
  
  # Singleton Methods
  # ==========================================================================
  
  
  # Step Components
  # ==========================================================================
  
  def_step_component :empty,
    "empty/no arguments" \
  do
    [ Meta::Args::Array.new ]
  end
  
  
  def_step_component :inline,
    "(the )arguments {values}" \
  do |values|
    [ args_for_positional_values( values ) ]
  end
  
  
  def_step_component :multiline,
    "(the )arguments:" \
  do |multiline|
    if multiline.is_a? ::Cucumber::MultilineArgument::DataTable
      [ args_for_data_table( multiline ) ]
    else
      [ scope_eval( "::NRSER::Meta::Args::Array.new( #{ multiline } )" ) ]
    end
  end
  
  
  def_step_component :single_string,
    "(the )single string argument:" \
  do |string|
    [ Meta::Args::Array.new( string ) ]
  end
  
  
  def_step_component_variations :arguments,
    components[ :empty ],
    components[ :inline ],
    components[ :multiline ],
    components[ :single_string ]

  
  # Steps
  # ==========================================================================
  
  def_steps components[ :arguments ] do |args|
    describe :arguments,
      subject: args
  end  


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
