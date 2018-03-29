# frozen_string_literal: true

module NRSER::RSpex::ExampleGroup
  
  # @todo Document describe_use_case method.
  # 
  # @return [void]
  # 
  def describe_case *description, where: {}, **metadata, &body
    describe_x \
      *description,
      type: :case,
      bindings: where,
      metadata: metadata,
      &body
  end # #describe_case
  
  # Older name
  alias_method :describe_use_case, :describe_case
  
end # module NRSER::RSpex::ExampleGroup
