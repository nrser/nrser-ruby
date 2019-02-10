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

module Binds
  
  # Mixins
  # ==========================================================================
  
  extend Helpers
  
  
  # Steps
  # ==========================================================================
  
  X_METHOD = \
    Step "I bind " \
    do |described, method_name|
      describe :method,
        subject: subject.method( method_name.bare_name )
    end

  
end # module Bind

# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
