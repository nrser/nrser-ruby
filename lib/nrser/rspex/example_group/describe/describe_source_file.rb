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

# Create an example group covering a source file.
# 
# Useful for when method implementations are spread out across multiple
# files but you want to group examples by the source file they're in.
# 
# @note
#   Honestly, now that modules, classes and methods described through RSpex
#   add their source locations, this is not all that useful. But it was
#   there from before that, which is why for the moment it's still here.
# 
# @see #describe_x
#
# @param [String | Pathname] path
#   File path.
# 
# @param *description (see #describe_x)
# 
# @param [Hash<Symbol, Object>] metadata
#   RSpec metadata to set for the example group.
#   
#   See the `metadata` keyword argument to {#describe_x}.
#   
#   A `file` key is added pointed to the {Pathname} for `path` before
#   passing up to {#describe_x}.
# 
# @param &body (see #describe_x)
# 
# @return (see #describe_x)
# 
def describe_source_file path, *description, **metadata, &body
  path = path.to_pn
  
  describe_x \
    path,
    *description,
    type: :source_file,
    metadata: {
      source_file: path,
      **metadata,
    },
    &body
end


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpex
end # module NRSER
