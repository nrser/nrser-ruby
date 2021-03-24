# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Custom pretty-printing mixin {NRSER::Support::PP}
require 'nrser/support/pp'

require_relative './base'


# Refinements
# ============================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  StepComponent


# Definitions
# =======================================================================

class Base

  # Mixins
  # ==========================================================================
  
  # Custom pretty-printing integration
  include Support::PP
  
  # Mix in enumeration.
  include ::Enumerable
  
  
  # Config
  # ============================================================================
  
  pretty_print_config \
    ivars:    { except: { :@arity => :never, } },
    methods:  { only:   { arity: :always, } }
  
  
  # Attributes
  # ==========================================================================
  
  # The step component's name.
  # 
  # @return [::Symbol]
  #     
  attr_reader :name
  
  
  # Construct a new {Base}.
  # 
  def initialize name
    @name = t.Label.check!( name ).to_sym
  end
  
  
  # Do any necessary transformation to parameter values provided by Cucumber
  # when it matches a step containing this component.
  # 
  # Realizing classes must implement.
  # 
  # @param [::Array] args
  #   Parameter values from Cucumber.
  # 
  # @return [::Array]
  #   Transformed values. **Must** be the same length as `args`.
  # 
  def transform *args
    raise AbstractMethodError.new self, __method__
  end
  
  
  # Realizing classes must implement to fullfil {::Enumerable}.
  # 
  # @param [λ(?)⟶void] block
  #   Block that receives each..?
  # 
  # @return [self]
  # 
  def each &block
    raise AbstractMethodError.new self, __method__
  end
  
  
  def | component
    require_relative './variations'
    Variations.new "#{ name }_OR_#{ component.name }", self, component
  end
  
  
  def + component
    require_relative './sequence'
    Sequence.new "#{ name }__THEN__#{ component.name }", self, component
  end
  
end # class Base


# /Namespace
# =======================================================================

end # module StepComponent
end # module Cucumber
end # module Described
end # module NRSER
