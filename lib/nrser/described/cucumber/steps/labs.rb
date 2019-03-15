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

# New, unorganized and experimental shit. To enable, require this in your
# `features/support/env.rb` file or equivalent.
# 
module Labs
  
  # Mixins
  # ==========================================================================
  
  extend Helpers
  
  
  # Steps
  # ==========================================================================
  
  Step "I let {local_var_name} be {value}" do |local_var_name, value|
    let local_var_name, value
  end
  
  
  Step "I let {local_var_name} be:" do |local_var_name, string|
    let local_var_name, scope_eval( string )
  end
  
end # module Labs


# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
