# frozen_string_literal: true

module NRSER::RSpex::ExampleGroup
  
  # Setup describes what's going to be *done* in all child examples.
  # 
  # It's where you setup your `subject`, usually depending on `let`
  # bindings that are provided in the children.
  # 
  # @return [void]
  # 
  def describe_setup *description, **metadata, &body
    describe_x \
      *description,
      type: :setup,
      metadata: metadata,
      &body
  end # #describe_setup
  
  alias_method :setup, :describe_setup
  alias_method :SETUP, :describe_setup
  
end # module NRSER::RSpex::ExampleGroup
