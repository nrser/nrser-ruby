# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Extends {Parameter}
require_relative "./parameter"

# Need to construct {Future}s
require_relative '../../resolution/future'


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  Described
class   SubjectFrom


# Definitions
# =======================================================================

# Class for {Parameter}s whose values can be resolved from {Described::Base} 
# instances in the {Hierarchy} in use.
# 
# This class implements all the necessary functionality, requiring only the 
# {#method_name} - `"subject"` for {Described::Base#subject} or `"error"` for
# {Described::Base#error} - to call to get the value from descriptions.
# 
# In practice, the descriptive subclasses {SubjectOf} and {ErrorOf} are used,
# which pass the appropriate {#method_name} up to {#initialize}.
# 
# @immutable
# 
class Resolvable < Parameter
  
  # @!attribute [r] described_class
  #   The subclass of {Described::Base} that this parameter should get it's 
  #   values from.
  #   
  #   @return [::Class<Described::Base>]
  #   
  prop  :described_class,
        type: t.SubclassOf( Described::Base )
  
  
  # @!attribute [r] method_name
  #   Name of the method to use to extract the value from resolved descriptions.
  #   
  #   @return [NRSER::Meta::Names::Method::Bare]
  #   
  prop  :method_name,
        type: t.IsA( NRSER::Meta::Names::Method::Bare )
  
  
  # Construct a new {Resolvable}.
  # 
  # @param [Class<Described::Base>] described_class
  #   The subclass of {Described::Base} that this parameter should get it's 
  #   values from.
  #   
  # @param [#to_s] method_name
  #   The 
  # 
  def initialize described_class, method_name
    initialize_props \
      described_class: described_class,
      method_name: NRSER::Meta::Names::Method::Bare.new( method_name )
  end
  
  
  # Does `object` satisfy the type of values we're looking for?
  # 
  # In detail, does it satisfy the {Types::Type} that calling {#method_name}
  # on instances of {#described_class} produces?
  # 
  # The {Types::Type} in question is obtained by sending
  # `"#{ method_name }_type"` to the {#described_class}.
  # 
  # In practice, we're calling {Described::Base.subject_type} or 
  # {Described::Base.error_type}, then {Types::Type#test?}-ing `object`.
  # 
  # @note
  #   This method takes care not to raise - if obtaining the type or testing 
  #   `object` fails, it will log a warning or error (respectively) and 
  #   return `false`.
  # 
  # @param [::Object] object
  #   Value to test.
  # 
  # @return [Boolean]
  #   `true` if `object` matches the value type for {#described_class} and 
  #   {#method_name}.
  # 
  def match_value_type? object
    value_type_method_name = "#{ method_name }_type"
    
    unless described_class.respond_to?( value_type_method_name )
      logger.warn(
        "Described class does not respond to value type method name, unable " +
        "to test values."
      ) do {
        described_class: described_class,
        value_type_method_name: value_type_method_name,
      } end
      
      return false
    end
    
    value_type = described_class.public_send value_type_method_name
    
    value_type.test? object
    
  rescue Exception => error
    logger.error "Error when matching value type", error do {
      described_class: described_class,
      value_type_method_name: value_type_method_name,
    } end
    
    false
  end # match_value_type?
  
  
  # Is `object` a suitable value or a {Described::Base} able to produce a 
  # suitable value for the parameter?
  # 
  # @return [true]
  #   If `object` is an instance of {#described_class} or if 
  #   {#match_value_type?} returns `true` when called with it.
  # 
  # @return [false]
  #   Otherwise.
  # 
  def match? object
    object.is_a?( described_class ) || match_value_type?( object )
  end
  
  
  # @return [Resolution::Future]
  # 
  # @return [nil]
  #   `object` will not resolve a value for this matcher now or in the future.
  # 
  def futurize object
    if object.is_a? Described::Base
      if object.is_a? described_class
        Resolution::Future.new \
          described: object,
          method_name: method_name.to_sym
      end
      
    elsif described_class.subject_type.test? object
      Resolution::Future.new value: object
      
    else
      nil
      
    end
  end
  
  
  # Language Integration Instance Methods
  # --------------------------------------------------------------------------
  
  # A short string summary of the instance.
  # 
  # @return [::String]
  # 
  def to_s
    "#{ self.class }[ #{ described_class.to_s } ]"
  end
  
  
  # Override to just use {#to_s}, which is nice, short, and has what you need
  # to know.
  # 
  # @param [::PP] pp
  # @return [nil]
  # 
  def pretty_print pp
    pp.text to_s
    nil
  end
  
end # class Resolvable


# /Namespace
# =======================================================================

end # class SubjectFrom
end # module Described
end # module NRSER
