# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/meta/args/array'

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

module Responses
  
  # Mixins
  # ==========================================================================
  
  extend Helpers
  
  
  # Steps
  # ==========================================================================
  
  CALL_IT_WITH_NO_ARGS,
  CALL_THE_METHOD_WITH_NO_ARGS = \
    [
      "I call it with no arguments",
      "I call the method with no arguments"
    ].map do |template|
      Step template do
        describe :response,
          args: Meta::Args::Array.new
      end
    end

  CALL_IT, CALL_THE_METHOD = \
    [
      "I call it( with the arguments)",
      "I call the method( with the arguments)"
    ].map do |template|
      Step template do
        describe :response
      end
    end

  CALL_METHOD_NAME = \
    Step "I call {method_name}( with the arguments)" do |method_name|
      describe_method method_name
      describe :response
    end
  
  CALL_METHOD_NAME_WITH_NO_ARGS = \
    Step "I call {method_name} with no arguments" do |method_name|
      # TODO  This *should* work, but it doesn't yet...
      # describe :response, 
      #   args: Meta::Args::Array.new,
      #   callable: describe_method( method_name )
      
      # So we do this...
      describe_method method_name
      describe :response, 
        args: Meta::Args::Array.new
    end
    
  # CALL_METHOD_NAME_ON_X_WITH_NO_ARGS = \
    Step "I call {method_name} on the {described} with no arguments" \
    do |method_name, described|
      describe :response,
        callable: describe( :method, object: described, name: method_name ),
        args: Meta::Args::Array.new
    end
  
  CALL_METHOD_NAME_WITH_ARGS = \
    Step "I call {method_name} with {values}" do |method_name, values|
      describe_method method_name
      # describe_positional_args values
      describe :response,
        args: args_for_positional_values( values )
    end
    
    Step "I call {method_name} on the {described} with {values}" \
    do |method_name, described, values|
      describe :response,
        callable: describe( :method, object: described, name: method_name ),
        args: args_for_positional_values( values )
    end
  
  CALL_IT_WITH_ARGUMENTS,
  CALL_THE_METHOD_WITH_ARGUMENTS = \
    [
      "I call it with {values}",
      "I call the method with {values}",
    ].map do |template|
      Step template do |values|
        describe :response, args: args_for_positional_values( values )
      end
    end
  
end # module Responses

# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
