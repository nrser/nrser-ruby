# frozen_string_literal: true

module NRSER::RSpex::ExampleGroup
  
  # @todo Document describe_instance method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def describe_instance *constructor_args, &body
    describe_x_type ".new(", Args(*constructor_args), ")",
      type: :instance,
      metadata: {
        constructor_args: constructor_args,
      },
      # subject_block: -> { super().new *described_args },
      subject_block: -> { super().new *described_constructor_args },
      &body
  end # #describe_instance
  
end # module NRSER::RSpex::ExampleGroup
