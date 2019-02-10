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

# Describe a "section". Just like {RSpec.describe} except it:
# 
# 1.  Expects a string title.
#     
# 2.  Prepends a little section squiggle `§` to the title so sections are
#     easier to pick out visually.
#     
# 3.  Adds `type: :section` metadata.
# 
# @param *description (see #describe_x)
# 
# @param [Hash<Symbol, Object>] metadata
#   RSpec metadata to set for the example group.
#   
#   See the `metadata` keyword argument to {#describe_x}.
#   
# @param &body (see #describe_x)
# 
# @return (see #describe_x)
# 
def describe_section *description, **metadata, &body
  # Pass up to {#describe_x}
  describe_x \
    *description,
    type: :section,
    metadata: metadata,
    &body
end # #describe_section

# BOLD NAME!
alias_method :SECTION, :describe_section


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpec
end # module NRSER
