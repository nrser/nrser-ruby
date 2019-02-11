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

# Describe any {::Object}. Replaces the previous `#SUBJECT` method with
# something that {Described} already has, though I don't see much use for it.
#
# @return [void]
#
def OBJECT object, **metadata, &body
  DESCRIBE :object,
    subject: object,
    metadata: metadata,
    &body
end # #OBJECT


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpec
end # module Described
end # module NRSER
