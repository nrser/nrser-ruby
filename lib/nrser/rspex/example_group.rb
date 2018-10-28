# encoding: UTF-8
# frozen_string_literal: true



# Requirements
# ========================================================================

# Stdlib
# ------------------------------------------------------------------------

# Deps
# ------------------------------------------------------------------------

# Project / Package
# ------------------------------------------------------------------------

# Sub-tree
require_relative './example_group/describe'
require_relative './example_group/logger'
require_relative './example_group/overrides'

# Namespace
# =======================================================================

module  NRSER
module  RSpex


# Definitions
# ========================================================================

# Extension methods that are mixed in to {RSpec::Core::ExampleGroup}.
# 
module ExampleGroup

  # Mix in the describe methods
  include Describe

end # module ExampleGroup


# /Namespace
# ========================================================================

end # module RSpex
end # module NRSER
