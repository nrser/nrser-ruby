# encoding: UTF-8
# frozen_string_literal: true

module NRSER::RSpex::ExampleGroup
  
  # Describe an attribute of the parent subject.
  # 
  # @return [void]
  # 
  def describe_attribute symbol, **metadata, &body
    describe_x \
      NRSER::RSpex::Format.md_code_quote( "##{ symbol }" ),
      type: :attribute,
      metadata: metadata,
      subject_block: -> {
        super().public_send symbol
      },
      &body
  end # #describe_attribute

  # Shorter name
  alias_method :describe_attr, :describe_attribute
  
end # module NRSER::RSpex::ExampleGroup
