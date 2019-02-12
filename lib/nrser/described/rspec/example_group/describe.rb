# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require 'nrser/described/hierarchy/node'
require 'nrser/described/rspec/example_hierarchy'
require 'nrser/described/rspec/ext'

# Sub-tree
require_relative './describe/attribute'
require_relative './describe/response'
require_relative './describe/case'
require_relative './describe/class'
require_relative './describe/each'
require_relative './describe/instance_method'
require_relative './describe/instance'
require_relative './describe/method'
require_relative './describe/module'
require_relative './describe/object'
require_relative './describe/setup'
require_relative './describe/spec_file'
require_relative './describe/when'
require_relative './describe/describe_x'


# Namespace
# ========================================================================

module  NRSER
module  Described
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
  
  def hierarchy
    metadata[ :hierarchy ]
  rescue ::NameError => error
    # NOTE  When included in the top-level there won't be any {#metadata}
    #       method.
    nil
  end
  
  
  # The current (latest added) {Described::Base} instance (if any).
  # 
  # @note
  #   This does **not** include "custom" subjects in *any way* ("custom"
  #   subjects are "normal" RSpec `subject { ... }` definitions in example
  #   groups, which we *do* cast into {Described::Base} in the 
  #   {ExampleHierarchy} returned by example's {Example#hierarchy} methods).
  # 
  # @return [Described::Base]
  #   When a description instance has been added to this or a ancestor example
  #   group.
  # 
  # @return [nil]
  #   When no description instances have been added.
  # 
  def described
    metadata[ :described ]
  rescue ::NameError => error
    # When included in the top-level there won't be any {#metadata}
    #       method.
    nil
  end
  
  
  def self_described
    @self_described
  end
  
  
  # Does this example group define a "custom" (non-described) subject
  # block?
  # 
  # @return [Boolean]
  # 
  def custom_subject?
    self_described.nil? && instance_methods( false ).include?( :subject )
  end # #custom_subject?
  
  
  # Has there been a "custom" (non-described) subject defined in this example
  # group or any of its ancestors walking up the nesting tree?
  # 
  # This is important because custom subjects can only be accessed from
  # examples, meaning {Described::Base} instances will have to wait until we
  # are running the examples to resolve (since they may depend on the values
  # of the custom subjects).
  # 
  # @return [Boolean]
  # 
  def custom_subject_in_ancestry?
    example_group = self
    
    while example_group.is_a?( ::Class ) &&
          example_group < ::RSpec::Core::ExampleGroup
      return true if example_group.custom_subject?
      example_group = example_group.superclass
    end
    
    false
  end # #custom_subject_in_ancestry?
  
  
  def DESCRIBE  described_class_name,
                description: nil,
                metadata: {},
                **kwds,
                &body
    self_described = \
      NRSER::Described.
        class_for_name( described_class_name ).
        new( **kwds )
    
    hierarchy = if self.hierarchy
      self.hierarchy.add self_described
    else
      Hierarchy::Node.new self_described
    end
    
    # *Try* to resolve to description. It may fail if it needs others that will
    # be defined further inside, but many (most?) will succeed at this point,
    # which lets us contribute nicer description strings for the output
    unless custom_subject_in_ancestry?
      begin
        self_described.resolve! hierarchy
      rescue Described::Resolution::AllFailedError => error
        # pass, will need to resolve later...
      end
    end
    
    describe(
      self_described.rspec_description,
      **metadata,
      described: self_described,
      hierarchy: hierarchy,
    ) do
      @self_described = self_described
      
      subject {
        self_described.resolve!( self.hierarchy )
        
        if self_described.subject?
          self_described.subject
        else
          raise self_described.error
        end
      }
      
      module_exec &body
    end
  end # #DESCRIBE
  
end # module Describe


# /Namespace
# ========================================================================

end # module  ExampleGroup
end # module  RSpec
end # module  Described
end # module  NRSER
