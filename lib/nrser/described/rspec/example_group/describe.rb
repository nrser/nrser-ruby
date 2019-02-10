# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

# Sub-tree
require_relative './describe/describe_attribute'
require_relative './describe/describe_bound_to'
require_relative './describe/describe_called_with'
require_relative './describe/describe_case'
require_relative './describe/describe_class'
require_relative './describe/describe_each'
require_relative './describe/describe_group'
require_relative './describe/describe_instance_method'
require_relative './describe/describe_instance'
require_relative './describe/describe_message'
require_relative './describe/describe_method'
require_relative './describe/describe_module'
require_relative './describe/describe_response_to'
require_relative './describe/describe_section'
require_relative './describe/describe_sent_to'
require_relative './describe/describe_setup'
require_relative './describe/describe_source_file'
require_relative './describe/describe_spec_file'
require_relative './describe/describe_subject'
require_relative './describe/describe_when'
require_relative './describe/describe_x'


# Namespace
# ========================================================================

module  NRSER
module  RSpec
module  ExampleGroup


# Definitions
# ========================================================================

# The core of {RSpec} - example group extension that provides contextual
# "describe" methods for things like modules, classes, methods, etc.
# 
# All methods boil-down to calling {RSpec.describe}, but first process 
# contextual parameters, create metadata, etc.
# 
# "Describe" methods are separated into their own submodule that is mixed in
# to {RSpec::ExampleGroup} so that they can also be mixed in to the top-level
# scope to expose the methods globally, allowing you to start a file with 
# just
# 
#     SPEC_FILE( ... ) do
# 
# Methods are defined in separate source files for organization's sake.
# 
module Describe
end # module Describe


# /Namespace
# ========================================================================

end # module ExampleGroup
end # module RSpec
end # module NRSER
