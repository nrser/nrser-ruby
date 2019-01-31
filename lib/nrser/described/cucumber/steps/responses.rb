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

module Responses
  
  # Mixins
  # ==========================================================================
  
  extend Helpers
  
  
  # Steps
  # ==========================================================================
  
  CALL_IT_WITH_NO_PARAMETERS, CALL_THE_METHOD_WITH_NO_PARAMETERS = \
    [
      "I call it with no parameters",
      "I call the method with no parameters"
    ].map do |template|
      Step template do
        describe :response, params: Meta::Params.new
      end
    end

  CALL_IT, CALL_THE_METHOD = \
    [
      "I call it( with the parameters)",
      "I call the method( with the parameters)"
    ].map do |template|
      Step template do
        describe :response
      end
    end

  CALL_METHOD_NAME = \
    Step "I call {method_name}( with the parameters)" do |method_name|
      describe_method method_name
      describe :response
    end
  
  CALL_METHOD_NAME_WITH_NO_PARAMETERS = \
    Step "I call {method_name} with no parameters" do |method_name|
      # TODO  This *should* work, but it doesn't yet...
      # describe :response, 
      #   params: Meta::Params.new,
      #   callable: describe_method( method_name )
      
      # So we do this...
      describe_method method_name
      describe :response, 
        params: Meta::Params.new
    end
  
  CALL_METHOD_NAME_WITH_PARAMETERS = \
    Step "I call {method_name} with {values}" do |method_name, values|
      describe_method method_name
      describe_positional_params values
      describe :response
    end
  
end # module Responses

# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
