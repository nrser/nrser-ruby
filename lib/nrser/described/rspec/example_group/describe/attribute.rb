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

# Describe an attribute of the parent subject.
# 
# @return [void]
# 
def ATTRIBUTE name, **metadata, &body
  DESCRIBE :attribute,
    name: Meta::Names::Method.from( name ).bare_name,
    &body
end # #ATTRIBUTE


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpec
end # module Described
end # module NRSER
