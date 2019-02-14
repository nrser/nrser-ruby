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

module Attributes
  
  # Mixins
  # ==========================================================================
  
  extend Helpers
  
  
  # Steps
  # ==========================================================================
  
  IMPLICIT_ATTRIBUTE = \
    Step "the attribute {method_name}" do |method_name|
      describe :attribute, name: method_name.bare_name
    end
  
  
  THE_X_HAS_ATTRIBUTE = \
    Step "the {described} has a(n) {method_name} attribute" \
    do |described, method_name|
      describe :attribute, object: described, name: method_name.bare_name
    end
  
  
  IT_HAS_ATTRIBUTE = \
    Step "it has a(n) {method_name} attribute" \
    do |method_name|
      describe :attribute, name: method_name.bare_name
    end
  
  
end # module Attributes

# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
