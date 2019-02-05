# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Project / Package ###

# {From::Parameter} are immutable, storing their property value in instance
# variables
require 'nrser/props/immutable/instance_variables'


# Namespace
# =======================================================================

module  NRSER
module  Described
class   SubjectFrom


# Definitions
# =======================================================================

# 
# @immutable
# 
class Parameter
  
  # Store property values in instance variables
  include NRSER::Props::Immutable::InstanceVariables
  
  
  # Instance factory.
  # 
  # @return [Parameter]
  # 
  def self.from object
    if object.is_a? Parameter
      object
      
    elsif Described::Base.subclass? object
      SubjectOf.new object
      
    else
      InitOnly.new object
    end
  end
  
  
  # Proxies to {.new}. Lets you write nifty-er things like
  # 
  #     subject_from SubjectFrom::ErrorOf[ Response ]
  # 
  # instead of oh so lame and easy to understand things like
  # 
  #     subject_from SubjectFrom::ErrorOf.new( Response )
  # 
  # @return [self]
  #   A new one of this.
  # 
  def self.[] *args, &block
    new *args, &block
  end
  
end # Parameter


# /Namespace
# =======================================================================

end # class SubjectFrom
end # module Described
end # module NRSER


# Post-Processing
# ============================================================================

#### Sub-Tree ####
require_relative "./init_only"
require_relative "./subject_of"
require_relative "./error_of"
