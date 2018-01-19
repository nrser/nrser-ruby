# frozen_string_literal: true

module NRSER::RSpex::ExampleGroup
  
  def describe_instance_method name, **metadata, &block
    describe(
      "#{ NRSER::RSpex::PREFIXES[:method] } #{ name }",
      type: :method,
      method_name: name,
      **metadata
    ) do
      if name.is_a? Symbol
        subject { super().method name }
      end
      
      module_exec &block
    end
  end # #describe_method
  
end # module NRSER::RSpex::ExampleGroup
