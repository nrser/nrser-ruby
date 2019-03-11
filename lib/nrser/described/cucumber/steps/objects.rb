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

module Objects
  
  # Mixins
  # ==========================================================================
  
  extend Helpers
  
  
  # Steps
  # ==========================================================================
  
  THE_OBJECT = \
    Step "the object {value}" do |value|
      describe :object, subject: value
    end
  
  THE_STRING_BLOCK, THE_STRING_INLINE = \
    [
      "a/the string:",
      "a/the string {string}",
    ].each do |template|
      Step template do |string|
        describe :string, subject: string
      end
    end
  
end # module Objects

# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
