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

# Describe a "use case".
# 
# @return [void]
# 
def CASE *description, where: {}, **metadata, &body
  describe_x \
    *description,
    type: :case,
    bindings: where,
    metadata: metadata,
    &body
end # #CASE


# /Namespace
# ========================================================================

end # module  Describe
end # module  ExampleGroup
end # module  RSpec
end # module  Described
end # module  NRSER
