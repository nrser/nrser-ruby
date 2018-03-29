# encoding: UTF-8
# frozen_string_literal: true

module NRSER::RSpex::ExampleGroup
  
  def describe_module mod, bind_subject: true, **metadata, &body
    describe_x \
      mod,
      type: :module,
      metadata: {
        module: mod,
        **metadata,
      },
      bind_subject: bind_subject,
      subject_block: -> { mod },
      &body
  end # #describe_module
  
end # module NRSER::RSpex::ExampleGroup
