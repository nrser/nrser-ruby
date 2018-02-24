# encoding: UTF-8
# frozen_string_literal: true

module NRSER::RSpex::ExampleGroup
  
  # @todo Document describe_method method.
  # 
  # @return [void]
  # 
  def describe_method method_name, *description, **metadata, &body
    # Due to legacy, we only auto-bind if the name is a symbol
    # 
    # TODO  Get rid of this
    # 
    subject_block = if method_name.is_a? Symbol
      -> { super().method method_name }
    end
    
    name_prefix = if  self.respond_to?( :metadata ) &&
                      self.metadata.key?( :constructor_args )
      '#'
    else
      '.'
    end
    
    name_string = NRSER::RSpex::Format.md_code_quote \
      "#{ name_prefix }#{ method_name }"
    
    # Create the RSpec example group context
    describe_x name_string, *description,
      type: :method,
      metadata: {
        **metadata,
        method_name: method_name,
      },
      subject_block: subject_block,
      &body
  end # #describe_method
  
end # module NRSER::RSpex::ExampleGroup
