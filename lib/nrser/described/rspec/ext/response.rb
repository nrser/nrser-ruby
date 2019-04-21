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
    args = init_values[ :args ]
  
    pos_args = [ Described::RSpec::Format::Args.new( args.args ) ]
    
    pos_args << args.block if args.block
  
    Described::RSpec::Format::Description.new \
      *pos_args,
      *additional_description,
      type: :called_with
  end
  
end # class Response


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
