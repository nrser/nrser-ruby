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
  
# Describe a "group". Doesn't really do much. Didn't end up getting used
# much. Probably not long for this world.
# 
# @param *description (see #describe_x)
# 
# @param [Hash<Symbol, Object>] metadata
#   RSpec metadata to set for the example group.
#   
#   See the `metadata` keyword argument to {#describe_x}.
# 
# @param &body          (see #describe_x)
# 
# @return (see #describe_x)
# 
def describe_group *description, **metadata, &body
  # Pass up to {#describe_x}
  describe_x \
    *description,
    type: :group,
    metadata: metadata,
    &body
end # #describe_group
  

# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpec
end # module NRSER
