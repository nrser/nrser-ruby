# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# =======================================================================

module  NRSER
module  RSpex
module  ExampleGroup
module  Describe


# Definitions
# ========================================================================

def describe_module mod, bind_subject: true, **metadata, &body
  describe_x \
    mod,
    type: :module,
    metadata: {
      module: mod,
      **metadata,
    },
    bind_subject: bind_subject,
    subject_block: -> { mod },
    &body
end # #describe_module

# Short name
alias_method :MODULE, :describe_module


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpex
end # module NRSER
