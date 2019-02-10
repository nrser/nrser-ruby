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
def describe_class  klass,
                    *description,
                    **metadata,
                    &body
  DESCRIBE \
    :class,
    subject: klass,
    description: description,
    metadata: metadata,
    &body
end # #describe_class

alias_method :CLASS, :describe_class
  

# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpec
end # module Described
end # module NRSER
