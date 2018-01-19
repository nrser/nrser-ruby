# frozen_string_literal: true

module NRSER::RSpex::ExampleGroup
  
  # Define a example group block with `let` bindings and evaluate the `body`
  # block in it.
  # 
  # @param [Hash<Symbol, Object>] **bindings
  #   Map of symbol names to value to bind using `let`.
  # 
  # @param [#call] &body
  #   Body block to evaluate in the context.
  # 
  # @return
  #   Whatever `context` returns.
  # 
  def describe_when *description, **bindings, &body
    describe_x \
      *description,
      type: :when,
      bindings: bindings,
      &body
  end
  
end # module NRSER::RSpex::ExampleGroup
