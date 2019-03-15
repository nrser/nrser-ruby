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

# Declare local variable bindings that will be made available when evaluating
# with {World::Scope#scope_eval}.
# 
# @note
#   At the moment, these declarations do **not** create description instances,
#   and I'm not sure if they will... I'm still working it out.
# 
module Lets
  
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
  
end # module Lets


# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
