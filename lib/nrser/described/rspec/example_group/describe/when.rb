# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# =======================================================================

module  NRSER
module  Described
module  RSpec
module  ExampleGroup
module  Describe


# Definitions
# ========================================================================

# Define a example group with the keyword args as bindings.
# 
# @see #describe_x
# 
# @param *description (see #describe_x)
# 
# @param [Hash<Symbol, Object>] bindings
#   See the `bindings` keyword arg in {#describe_x}.
# 
# @param &body (see #describe_x)
# 
# @return (see #describe_x)
# 
def WHEN *description, **bindings, &body
  describe_x \
    *description,
    type: :when,
    bindings: bindings,
    &body
end # #WHEN


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpec
end # module Described
end # module NRSER
