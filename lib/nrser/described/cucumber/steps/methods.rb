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

module Methods
  
  # Mixins
  # ==========================================================================
  
  extend Helpers
  
  
  # Steps
  # ==========================================================================
  
  THE_METHOD, ITS_METHOD = \
    [
      "the (instance )method {method_name}",
      "its method {method_name}"
    ].map do |template|
      Step template do |method_name|
        describe_method method_name
      end
    end
  
  
  X_METHOD = \
    Step "the {described}'(s) method {method_name}" \
    do |described, method_name|
      describe :method,
        subject: subject.method( method_name.bare_name )
    end
  
  
  BOUND_METHOD = \
    Step "I bind the instance method to the {described}" do |described|
      instance = if described.is_a?( Described::Instance )
        described
      else
        # if described.
        describe :instance, object: described
      end
      
      describe :method, instance: instance
    end
  
end # module Methods

# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
