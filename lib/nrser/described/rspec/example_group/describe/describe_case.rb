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

# Describe a "use case".
# 
# @return [void]
# 
def describe_case *description, where: {}, **metadata, &body
  describe_x \
    *description,
    type: :case,
    bindings: where,
    metadata: metadata,
    &body
end # #describe_case

alias_method :CASE, :describe_case


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpec
end # module NRSER
