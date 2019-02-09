# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Project / Package ###

require 'nrser/log'

# {From::Parameter} are immutable, storing their property value in instance
# variables
require 'nrser/props/immutable/instance_variables'


# Namespace
# =======================================================================

module  NRSER
module  Described
class   SubjectFrom


# Definitions
# ============================================================================

# {Parameter} instances exist only as values in {SubjectFrom#parameters}, where
# encapsulate information about the types and sources of values that are
# acceptable resolutions.
#
# Realizing subclasses implement {#match?} to test if objects are likely to
# satisfy them, as well as {#futurize} to convert both values sourced from
# {Described::Base#init_values} *or* instances of the {Described::Base} that the
# {Parameter} is attached to (through the {SubjectFrom} of which it is a 
# member) to {Resolution::Future} instances that are or will (hopefully) be 
# fulfilled to the actual value for the {Parameter}.
#
# @immutable
# @abstract
#
class Parameter
  
  # Store property values in instance variables
  include NRSER::Props::Immutable::InstanceVariables
  
  # Add {.logger} and {#logger} methods
  include NRSER::Log::Mixin
  
  
  # Instance factory.
  # 
  # @param [::Object] object
  #   Any old thang.
  # 
  # @return [Parameter]
  #   If `object` **already is** a {Parameter} instance it is returned.
  # 
  # @return [SubjectOf]
  #   If `object`...
  #   
  #   1.  **is not** a {Parameter} instance **and**
  #   2.  **is** a subclass of {Described::Base}.
  # 
  #   a {SubjectOf.new} instance is constructed from `object`.
  # 
  # @return [InitValue]
  #   If `object`...
  #   
  #   1.  **is not** a {Parameter} instance **and**
  #   2.  **is not** a subclass of {Described::Base}
  #   
  #   a {InitValue.new} instance is constructed from `object`.
  # 
  def self.from object
    if object.is_a? Parameter
      object
      
    elsif Described::Base.subclass? object
      SubjectOf.new object
      
    else
      InitValue.new object
    end
  end
  
  
  # Proxies to `.new`. Lets you write nifty-er things like
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
  
  
  # Is `object` a suitable value or a {Described::Base} able to produce a 
  # suitable value for the {Parameter}?
  # 
  # @abstract
  #   Realizing classes **must** implement this method.
  # 
  # @param [::Object] object
  # 
  # @return [Boolean]
  # 
  def match? object
    raise NRSER::AbstractMethodError.new self, __method__
  end
  
  
  # If `object` is suitable to be or resolve to a value for this {Parameter},
  # create a {Resolution::Future} that is or will be (errors aside) fulfilled 
  # to the value.
  # 
  # @abstract
  #   Realizing classes **must** implement this method.
  # 
  # @param [::Object] object
  #
  # @return [nil]
  #   When `object` is not suitable to be or resolve to a value for this 
  #   {Parameter}.
  #
  # @return [Resolution::Future]
  #   When `object` is suitable to be or resolve to a value for this
  #   {Parameter}, a future that is or will be fulfilled to that value is
  #   returned.
  #
  def futurize object
    raise NRSER::AbstractMethodError.new self, __method__
  end
  
end # Parameter


# /Namespace
# =======================================================================

end # class SubjectFrom
end # module Described
end # module NRSER
