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
  
end # module Objects

# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
