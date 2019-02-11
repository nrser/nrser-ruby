# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require 'nrser/described/hierarchy/node'
require 'nrser/described/rspec/example_hierarchy'

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
  
  def self.description_for described
    type = described.class.name.demodulize.underscore
    
    content = if described.resolved? && described.subject?
      described.subject
    else
      described
    end
    
    Described::RSpec::Format.description content, type: type
  end
  
  
  def hierarchy
    metadata[ :hierarchy ]
  end
  
  
  def described
    metadata[ :described ]
  end
  
  
  def self_described
    @self_described
  end
  
  
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
    begin
      self_described.resolve! hierarchy
    rescue Described::Resolution::AllFailedError => error
      # pass, will need to resolve later...
    end
    
    describe(
      Describe.description_for( self_described ),
      **metadata,
      described: self_described,
      hierarchy: hierarchy,
    ) do
      @self_described = self_described
      
      subject {
        self_described.resolve!( ExampleHierarchy.new self )
        
        if self_described.subject?
          self_described.subject
        else
          raise self_described.error
        end
      }
      
      module_exec &body
    end
  end # DESCRIBE
  
end # module Describe


# /Namespace
# ========================================================================

end # module  ExampleGroup
end # module  RSpec
end # module  Described
end # module  NRSER
