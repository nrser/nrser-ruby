# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require 'nrser/described/hierarchy'


# Namespace
# ========================================================================

module  NRSER
module  Described
module  RSpec


# Definitions
# ========================================================================

# A {Described::Hierarchy} interface 
# 
class ExampleHierarchy
  
  include Hierarchy
  
  def initialize example
    @example = example
  end
  
  
  def each &block
    return enum_for( __method__ ) if block.nil?
    
    example_group = @example.class
    
    while example_group < ::RSpec::Core::ExampleGroup
      if ( example_group_described = example_group.self_described)
        block.call example_group_described
        
      elsif example_group.instance_methods( false ).include? :subject
        subject_method = example_group.instance_method :subject
        
        begin
          subject = subject_method.bind( @example ).call
        rescue
        else
          block.call \
            Described::Object.new( subject: subject )
        end
          
      end
      
      example_group = example_group.superclass
    end
  end
  
  
end # class ExampleGroupHierarchy


# /Namespace
# ========================================================================

end # module  RSpec
end # module  Described
end # module  NRSER
