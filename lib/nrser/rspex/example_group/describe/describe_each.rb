# encoding: UTF-8
# frozen_string_literal: true


# Refinements
# ========================================================================

require 'nrser/refinements/sugar'
using NRSER::Sugar


# Namespace
# =======================================================================

module  NRSER
module  RSpex
module  ExampleGroup
module  Describe


# Definitions
# ========================================================================

# Describe an instance of the described class by providing arguments for
# it's construction.
# 
# @param [Array<Array>] lists
#   Arguments to pass to `.new` on {#described_class} to create instances.
# 
# @return (see #describe_x)
# 
def describe_each *lists, **metadata, &body
  names = body.parameters.map { |(type, symbol)| symbol }

  description = names.map { |name| "{ #{ name } }" }.join( ' × ' )

  describe_x \
    description,
    type: :each,
    metadata: {
      **metadata,
      each_lists: lists,
      each_names: names,
    } \
  do
    lists.first.product( *lists.n_x.rest ).each do |product|
      bindings = product.each_with_index.map { |value, index|
        [ names[ index ], value ]
      }.to_h

      describe_when **bindings do
        module_exec *product, &body
      end
    end
  end
end # #describe_instance

alias_method :EACH, :describe_each


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpex
end # module NRSER
