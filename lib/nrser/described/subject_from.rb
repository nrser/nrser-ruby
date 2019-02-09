# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Mixing in my custom pretty printing support
require "nrser/support/pp"

# {SubjectFrom} is immutable
require 'nrser/props/immutable/instance_variables'

# Need {Described::Base} for prop types
require_relative './base'

# Need {Parameter} for the prop types
require_relative "./subject_from/parameters"


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  Described


# Definitions
# =======================================================================

# {SubjectFrom} instances encapsulate how {Described::Base} instances can
# resolve their {Described::Base#subject} from other values, either parameters
# the description was initialized with or from subjects or errors of other
# descriptions in the relevant {Hierarchy}.
# 
# @immutable
#
# @note
#   You probably don't want or need to instantiate {SubjectFrom} instances
#   directly unless you are working on the library itself or an extension or
#   something.
#
#   {SubjectFrom} instances are generally declared in description class
#   definitions using the {Described::Base.subject_from} method.
#
class SubjectFrom
  
  # Mixins
  # ==========================================================================
  
  include NRSER::Props::Immutable::InstanceVariables
  
  
  # Properties
  # =====================================================================
  
  # @!attribute [r] parameters
  #   Information about the parameters needed to call {#block}.
  #   
  #   Keys are the {Symbol}s that will be used as keywords when calling {#block},
  #   and values are {Parameter} instances describing what objects are suitable
  #   for those keywords.
  #   
  #   @return [Hash<Symbol, Parameter>]
  #   
  prop  :parameters,
        type: t.Hash( keys: t.Symbol, values: Parameter )
  
  
  # @!attribute [r] block
  #   The function that transforms values for the {#parameters} into the
  #   {Described::Base#subject}.
  #   
  #   Will be called with a keyword arguments hash with each key {Symbol} from
  #   {#parameters} mapped to it's value.
  #   
  #   When this block raises, the {Described::Base} gets an 
  #   {Described::Base#error} values *instead* of a subject.
  #   
  #   @return [::Proc<(**VALUES)->SUBJECT)>]
  #   
  prop  :block,
        type: t.IsA( ::Proc )
  
  
  # Construction
  # ==========================================================================
  
  # Construct a new {SubjectFrom}.
  # 
  # @param [Hash<#to_sym, ::Object>] parameters
  #   Map to assign to {#parameters}, calling `#to_sym` on the keys and 
  #   passing values to {Parameter.from} to produce the necessary types.
  # 
  # @param [::Proc<(**VALUES)->SUBJECT)>]
  #   Function to turn values for {#parameters} into description subjects,
  #   see {#block}.
  # 
  def initialize parameters:, block:
    initialize_props(
      parameters: parameters.
                          map { |k, v|
                            [ k.to_sym, Parameter.from( v ) ]
                          }.
                          to_h,
      
      block: block,
    )
  end
  
  
  # Instance Methods
  # ==========================================================================
  
  # Language Integration Instance Methods
  # --------------------------------------------------------------------------
  
  # Override to just pretty-print the {#parameters}, since we can't print
  # much useful about the {#block}.
  # 
  # @param [::PP] pp
  # @return [nil]
  # 
  def pretty_print pp
    pp.group 1, "{#{self.class}", "}" do
      pp.breakable ' '
      
      pp.seplist parameters.sort, nil do |(name, value)|
        pp.group do
          pp.text "#{ name }: "
          
          pp.group 1 do
            pp.breakable ''
            pp.pp value
          end # group
          
        end # group
      end # seplist
      
    end # group
    
    nil
  end # #pretty_print
  
end # class SubjectFrom

# /Namespace
# =======================================================================

end # module Described
end # module NRSER
