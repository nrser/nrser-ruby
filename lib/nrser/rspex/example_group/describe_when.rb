# encoding: UTF-8
# frozen_string_literal: true

module NRSER::RSpex::ExampleGroup
  
  # Define a example group with the keyword args as bindings.
  # 
  # @see #describe_x
  # 
  # @param *description (see #describe_x)
  # 
  # @param [Hash<Symbol, Object>] **bindings
  #   See the `bindings` keyword arg in {#describe_x}.
  # 
  # @param &body (see #describe_x)
  # 
  # @return (see #describe_x)
  # 
  def describe_when *description, **bindings, &body
    describe_x \
      *description,
      type: :when,
      bindings: bindings,
      &body
  end
  
end # module NRSER::RSpex::ExampleGroup
