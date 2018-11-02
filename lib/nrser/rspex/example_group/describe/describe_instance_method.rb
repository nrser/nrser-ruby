# encoding: UTF-8
# frozen_string_literal: true

# Namespace
# =======================================================================

module  NRSER
module  RSpex
module  ExampleGroup
module  Describe


# Definitions
# ========================================================================

def describe_instance_method name,
                    *description,
                    bind_subject: true,
                    **metadata,
                    &body

  subject_block = -> {
    super_subject = super()
    
    if super_subject.is_a? Module
      super_subject.instance_method name
    else
      super_subject.method name
    end
  }

  describe_x \
    "##{ name }",
    *description,
    type: :instance_method,
    bind_subject: bind_subject,
    subject_block: subject_block,
    metadata: {
      **metadata,
      instance_method_name: name,
    },
    &body
end # #describe_method

alias_method :INSTANCE_METHOD, :describe_instance_method


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpex
end # module NRSER
