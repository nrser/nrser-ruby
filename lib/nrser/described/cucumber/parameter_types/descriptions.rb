# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Need {NRSER::Described.human_name_pattern}
require 'nrser/described'

# Need to extend in the {Declare} mixin to get `.declare`, etc.
require_relative './declare'


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  ParameterTypes


# Definitions
# =======================================================================

# Declarations of {Cucumber::Glue::DLS::ParameterType} construction values
# used to create parameter types that match {NRSER::Described::Base} instances
# in the description hierarchy.
# 
module Descriptions
  
  extend Declare
  
  
  DESCRIBED_NAME = def_parameter_type \
    name:           :described_name,
    patterns:       NRSER::Described.human_name_pattern,
    type:           ::String
  
  
  def_parameter_type \
    name:           :described,
    patterns:       DESCRIBED_NAME,
    type:           NRSER::Described::Base,
    transformer:    ->( string ) {
      find_described_by_human_name! string
    }
    
  
end # module Descriptions  


# /Namespace
# =======================================================================

end # module ParameterTypes
end # module Cucumber
end # module Described
end # module NRSER
