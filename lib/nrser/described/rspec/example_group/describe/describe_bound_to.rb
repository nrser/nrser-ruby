# encoding: UTF-8
# frozen_string_literal: true

# Namespace
# =======================================================================

module  NRSER
module  RSpec
module  ExampleGroup
module  Describe


# Definitions
# ========================================================================

def describe_bound_to receiver,
                      *description,
                      bind_subject: true,
                      **metadata,
                      &body

  subject_block = -> { super().bind receiver }
  
  description = [ receiver ] if description.empty?

  describe_x \
    *description,
    type: :bound_to,
    bind_subject: bind_subject,
    subject_block: subject_block,
    metadata: {
      **metadata,
      bound_to: receiver,
    },
    &body
end # #describe_method

alias_method :BOUND_TO, :describe_bound_to


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpec
end # module NRSER
