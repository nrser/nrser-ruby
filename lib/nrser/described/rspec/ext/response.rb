# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/described/response'


# Namespace
# =======================================================================

module  NRSER
module  Described


# Definitions
# =======================================================================

class Response < Object
  
  def rspec_description *additional_description
    params = init_values[ :params ]
  
    args = [ Described::RSpec::Format::Args.new( params.args ) ]
    
    args << params.block if params.block
  
    Described::RSpec::Format::Description.new \
      *args,
      *additional_description,
      type: :called_with
  end
  
end # class Response


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
