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

# Describe an attribute of the parent subject.
# 
# @return [void]
# 
def describe_attribute symbol, **metadata, &body
  symbol = symbol.to_sym

  describe_x \
    NRSER::RSpec::Format.md_code_quote( "##{ symbol }" ),
    type: :attribute,
    metadata: {
      **metadata,
      attribute_name: symbol,
    },
    subject_block: -> {
      super().public_send symbol
    },
    &body
end # #describe_attribute

# Shorter name
alias_method :describe_attr, :describe_attribute

# BOLDER name
alias_method :ATTRIBUTE, :describe_attribute


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpec
end # module NRSER
