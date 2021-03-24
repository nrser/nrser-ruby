# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require_relative './composite'


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

# A Cucumber step component that is composed of other step components.
# 
class Variations < Composite
  
  # Config
  # ============================================================================
  
  pretty_print_config \
    ivars: {
      mode: :defined,
      except: {
        :@transforming_components => :never,
        :@transform_args_type => :never,
      }
    }
  
  module Types
    Components = t.Array & ~t.Empty
  end

  
  # The components this one is composed of.
  # 
  # @immutable Frozen
  # 
  # @return [::Array<Expression | Sequence>]
  #     
  attr_reader :components
  
  
  def initialize name, *components
    super( name )
    
    (t.Array & t.
    t.NonEmptyArray.check! components
    
    @components = \
      components.flat_map { |component|
        # Simplify sub-variations. Also serves to check entry types.
        t.match component,
          # Expression, component,
          
          Variations, :components.to_proc,
          
          Base, component
      }.freeze
    
    unless  @components.
              map( &:arity ).
              all? { |arity| arity == @components[ 0 ].arity }
      raise ArgumentError.new \
        "All `components` must have same arity",
        arities: @components.map { |c| [ c.name, c.arity ] }.to_h
    end
  end
  
  
  def arity
    components[ 0 ].arity
  end
  
  
  def each &block
    return enum_for( __method__ ) unless block
    
    components.each do |component|
      block.call [ component ]
    end
    
    self
  end
  
end # class Variations


# /Namespace
# =======================================================================

end # module StepComponent
end # module Cucumber
end # module Described
end # module NRSER
