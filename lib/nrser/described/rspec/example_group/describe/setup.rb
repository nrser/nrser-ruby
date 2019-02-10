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

# Setup describes what's going to be *done* in all child examples.
# 
# It's where you setup your `subject`, usually depending on `let`
# bindings that are provided in the children.
# 
# @return [void]
# 
def SETUP *description, **metadata, &body
  describe_x \
    *description,
    type: :setup,
    metadata: metadata,
    &body
end # #SETUP


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpec
end # module Described
end # module NRSER
