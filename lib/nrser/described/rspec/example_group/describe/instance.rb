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


def NEW *args, **kwds, &body
  params = Meta::Params.new args: args, kwds: kwds
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
def INSTANCE_FROM method_name, *args, **kwds, &body
  params = Meta::Params.new args: args, kwds: kwds
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
