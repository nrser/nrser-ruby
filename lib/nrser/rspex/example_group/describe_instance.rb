# frozen_string_literal: true

module NRSER::RSpex::ExampleGroup
  
  # Describe an instance of the described class by providing arguments for
  # it's construction.
  # 
  # @param [Array] constructor_args
  #   Arguments to pass to `.new` on {#described_class} to create instances.
  # 
  # @return [void]
  # 
  def describe_instance *constructor_args, &body
    describe_x ".new", Args(*constructor_args),
      type: :instance,
      metadata: {
        constructor_args: constructor_args,
      },
      subject_block: -> {
        described_class.new *described_constructor_args
      },
      &body
  end # #describe_instance
  
end # module NRSER::RSpex::ExampleGroup
