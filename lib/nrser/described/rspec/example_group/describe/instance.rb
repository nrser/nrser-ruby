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

# Describe an instance of the described class by providing arguments for
# it's construction.
# 
# @param [Array] constructor_args
#   Arguments to pass to `.new` on {#described_class} to create instances.
# 
# @return [void]
# 
def INSTANCE *args, **kwds, &body
  params = Meta::Params.new args: args, kwds: kwds
  DESCRIBE :instance, params: params, &body
end # #INSTANCE

alias_method :INSTANCE_FROM, :INSTANCE


# /Namespace
# ========================================================================

end # module  Describe
end # module  ExampleGroup
end # module  RSpec
end # module  Described
end # module   NRSER
