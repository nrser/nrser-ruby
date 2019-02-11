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
  
# Describe a {::Class}.
# 
# @return [void]
# 
def CLASS   class_,
            *description,
            **metadata,
            &body
  DESCRIBE \
    :class,
    subject: class_,
    description: description,
    metadata: {
      **metadata,
      class: class_,
    },
    &body
end # #CLASS
  

# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpec
end # module Described
end # module NRSER
