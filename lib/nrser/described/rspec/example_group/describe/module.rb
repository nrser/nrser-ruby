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

def MODULE module_, *description, **metadata, &body
  DESCRIBE :module,
    subject: module_,
    description: description,
    metadata: {
      **metadata,
      module: module_,
    },
    &body
end # #MODULE


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpec
end # module Described
end # module NRSER