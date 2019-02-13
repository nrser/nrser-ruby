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

# Methods mixed in to {::RSpec::Core::ExampleGroup} to use {Described}.
# 
module Describe
  
  # The group (singleton-level) {Hierarchy}. Only includes {Described::Base}
  # instances defined with {#DESCRIBE} and friends, no casted "custom" 
  # subjects like {Example#hierarchy} (because they're not available in the
  # example group context).
  # 
  # @return [Hierarchy::NodeHierarchy]
  #   When a {Described::Base} has been defined in this or an ancestor example
  #   group. From `#metadata[ :hierarchy ]`.
  # 
  # @return [nil]
  #   When no {Described::Base} has been defined in this or an ancestor example
  #   group.
  # 
  def hierarchy
    metadata[ :hierarchy ]
  rescue ::NameError => error
    # NOTE  When included in the top-level there won't be any {#metadata}
    #       method.
    nil
  end
  
  
  # The current (latest added) {Described::Base} instance (if any). Gets it
  # from the `#metadata`.
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
  
  
  # The {Described::Base} attached to *this* instance, if any.
  # 
  # @return [Described::Base]
  #   When this example group is a described one.
  # 
  # @return [nil]
  #   When this example group is not a described one.
  # 
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
