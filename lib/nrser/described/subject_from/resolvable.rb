# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Extends {Parameter}
require_relative "./parameter"

# Need to construct {Future}s
require_relative '../resolution/future'


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


# @immutable
# 
class Resolvable < Parameter
  
  # @!attribute [r] described_class
  #   The description class this match-extractor will match instances of.
  #   
  #   @return [::Class<Described::Base>]
  #   
  prop  :described_class,
        type: t.SubclassOf( Described::Base )
  
  
  # @!attribute [r] method_name
  #   Name of the method to use - `subject` or `error` - to extract the 
  #   value from resolved descriptions.
  #   
  #   @return [NRSER::Meta::Names::Method::Bare]
  #   
  prop  :method_name,
        type: t.IsA( NRSER::Meta::Names::Method::Bare )
  
  
  def initialize described_class, method_name
    initialize_props \
      described_class: described_class,
      method_name: NRSER::Meta::Names::Method::Bare.new( method_name )
  end
  
  
  def match? object
    object.is_a?( described_class ) ||
      described_class.subject_type.test?( object )
  end
  
  
  # @return [Future]
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
  
  def pretty_print pp
    pp.group 1, "#{ self.class }[", "]" do
      pp.breakable " "
      pp.text described_class.to_s
      pp.breakable " "
    end
  end
  
end # class Resolvable


# /Namespace
# =======================================================================

end # class SubjectFrom
end # module Described
end # module NRSER
