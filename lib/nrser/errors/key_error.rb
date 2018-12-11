# frozen_string_literal: true
# encoding: UTF-8

# Requirements
# ========================================================================

# Make nice(r)
require_relative './nicer_error'


# Namespace
# ========================================================================

module  NRSER


# Definitions
# ========================================================================

# Raised when there is a problem with a *value* that does not fall into one
# of the other built-in exception categories (non-exhaustive list):
# 
# 1.  It's the wrong type (TypeError)
# 2.  It's an argument (ArgumentError)
# 
# It is encouraged to attach the invalid value as the `value:` keyword argument,
# which is then stored in {#context} hash and can be accessed via {#value}.
# 
class KeyError < ::KeyError

  # Play nice :)
  include NicerError

end # class ValueError


# /Namespace
# ========================================================================

end # module NRSER