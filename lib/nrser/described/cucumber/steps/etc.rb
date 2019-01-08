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

module Etc
  
  # Mixins
  # ==========================================================================
  
  extend Helpers
  
  
  # Steps
  # ==========================================================================
  
  REQUIRE = \
    Step "I require {string}" do |string|
      require string
    end
  
  EVAL = \
    Step "I evaluate:" do |source|
      scope.module_eval source, "(given eval src)", 1
    end
  
  EVAL_IN = \
    Step "I evaluate the following in the class {class}:" do |class_, source|
      class_.
        # resolve!( hierarchy ).
        class_eval source, "(#{ class_.name }.class_eval src)", 1
    end
  
end # module Etc

# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
