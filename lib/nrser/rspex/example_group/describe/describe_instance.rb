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

# Describe an instance of the described class by providing arguments for
# it's construction.
# 
# @param [Array] constructor_args
#   Arguments to pass to `.new` on {#described_class} to create instances.
# 
# @return [void]
# 
def describe_instance *constructor_args, &body
  constructor_args = Args *constructor_args

  constructor = -> {
    # binding.pry
    described_class.new *constructor_args # *described_constructor_args
  }

  subject_block = if metadata[ :instance_method_name ]
    -> {
        described_class.
          new( *constructor_args ).
          method( self.class.metadata[ :instance_method_name ] )
      }
  else
    -> { described_class.new *constructor_args }
  end

  describe_x ".new", constructor_args,
    type: :instance,
    metadata: {
      constructor_args: constructor_args,
    },
    subject_block: subject_block,
    &body
end # #describe_instance

alias_method :INSTANCE, :describe_instance


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpex
end # module NRSER
