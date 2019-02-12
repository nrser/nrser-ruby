# encoding: UTF-8
# frozen_string_literal: true

# Namespace
# =======================================================================

module  NRSER
module  Described
module  RSpec
module  ExampleGroup
module  Describe


# Definitions
# ========================================================================

# Describe an instance of a class by providing the instance itself.
# 
def INSTANCE instance, *description, **metadata, &body
  DESCRIBE :instance, *description,
    subject: instance,
    metadata: metadata,
    &body
end


def NEW *args, &body
  block = nil

  if args[ -1 ].is_a? Wrappers::Block
    block = args[ -1 ]
    args = args[ 0..-2 ]
  end

  params = Meta::Params::Simple.new *args, &block
  DESCRIBE :instance,
    params: params, &body
end

alias_method :NEW_INSTANCE, :NEW


# Describe an instance of the described class by providing arguments for
# it's construction.
# 
# @param [Array] constructor_args
#   Arguments to pass to `.new` on {#described_class} to create instances.
# 
# @return [void]
# 
def INSTANCE_FROM method_name, *args, &body
  block = nil

  if args[ -1 ].is_a? Wrappers::Block
    block = args[ -1 ]
    args = args[ 0..-2 ]
  end

  params = Meta::Params::Simple.new *args, &block
  
  DESCRIBE :instance,
    method_name: Meta::Names::Method::Bare.new( method_name ),
    params: params, &body
end # #INSTANCE_FROM


# /Namespace
# ========================================================================

end # module  Describe
end # module  ExampleGroup
end # module  RSpec
end # module  Described
end # module   NRSER
