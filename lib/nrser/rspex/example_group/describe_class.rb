# encoding: UTF-8
# frozen_string_literal: true

module NRSER::RSpex::ExampleGroup
  
  # @todo Document describe_class method.
  # 
  # @return [void]
  # 
  def describe_class  klass,
                      *description,
                      bind_subject: true,
                      **metadata,
                      &body
    subject_block = if bind_subject
      -> { klass }
    end
    
    describe_x \
      NRSER::RSpex::Format.md_code_quote( klass.name ),
      klass.source_location,
      *description,
      type: :class,
      metadata: {
        **metadata,
        class: klass,
      },
      subject_block: subject_block,
      &body
  end # #describe_class
  
  alias_method :CLASS, :describe_class
  
end # module NRSER::RSpex::ExampleGroup
