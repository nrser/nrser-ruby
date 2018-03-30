# frozen_string_literal: true
# encoding: utf-8


# Declarations
# =======================================================================

module NRSER::RSpex; end
module NRSER::RSpex::ExampleGroup; end


# Sub-Tree
# ============================================================================

require_relative './example_group/overrides'

require_relative './example_group/describe_attribute'
require_relative './example_group/describe_called_with'
require_relative './example_group/describe_case'
require_relative './example_group/describe_class'
require_relative './example_group/describe_group'
require_relative './example_group/describe_instance_method'
require_relative './example_group/describe_instance'
require_relative './example_group/describe_message'
require_relative './example_group/describe_method'
require_relative './example_group/describe_module'
require_relative './example_group/describe_response_to'
require_relative './example_group/describe_section'
require_relative './example_group/describe_sent_to'
require_relative './example_group/describe_setup'
require_relative './example_group/describe_source_file'
require_relative './example_group/describe_spec_file'
require_relative './example_group/describe_when'
require_relative './example_group/describe_x'
