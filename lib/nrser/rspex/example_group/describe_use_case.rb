# frozen_string_literal: true

module NRSER::RSpex::ExampleGroup
  
  # @todo Document describe_use_case method.
  # 
  # @return [void]
  # 
  def describe_use_case *description, where: {}, **metadata, &body
    describe_x \
      *description,
      type: :use_case,
      bindings: where,
      metadata: metadata,
      &body
  end # #describe_use_case
  
end # module NRSER::RSpex::ExampleGroup
