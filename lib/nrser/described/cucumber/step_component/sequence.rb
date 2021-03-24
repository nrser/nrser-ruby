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
class Sequence < Composite
  
  module Types
    Components = t.Array( t.IsA( Base ) | t.String )
  end
  
  
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
    
    
  # Singleton Methods
  # ==========================================================================
  
  def self.expand component, *rest, &block
    if rest.empty?
      if component.is_a? ::String
        block.call [ component ]
      else
        component.each &block
      end
    else
      expand *rest do |expansion|
        if component.is_a? ::String
          block.call [ component, *expansion ]
        else
          component.each do |entry|
            block.call [ *entry, *expansion ]
          end
        end
      end
    end
  end # .expand

  
  # The components this one is composed of.
  # 
  # @immutable Frozen
  # 
  # @return [::Array<::String | Base>]
  #     
  attr_reader :components
  
  
  # Components that are other {StepComponent::Base} instance, and hence partake
  # in {#transform}.
  # 
  # @immutable Frozen
  # 
  # @return [::Array<Base>]
  #     
  attr_reader :transforming_components
  
  
  # The type of both the arguments *and* respond to {#transform}.
  # 
  # @return [::NRSER::Types::Type]
  # 
  attr_reader :transform_args_type
  
  
  # TODO document `arity` attribute.
  # 
  # @return [::Integer]
  #     
  attr_reader :arity
  
  
  def initialize name, *components
    super( name )
    @components = Types::Components.check! components.freeze
    @transforming_components = components.select &t( Base )
    @arity = transforming_components.map( &:arity ).reduce :+
    @transform_args_type = t.Array & t.Length( arity )
  end
  
  
  def transform *args
    transform_args_type.check! args
    
    transform_args_type.check! \
      transforming_components.flat_map { |component|
        component.transform *args.shift( component.arity )
      }
  end
  
  
  def each &block
    return enum_for( __method__ ) unless block
    
    self.class.expand *components, &block
    
    self
  end
  
  
  def to_a
    each.to_a
  end
  
end # class Sequence


# /Namespace
# =======================================================================

end # module StepComponent
end # module Cucumber
end # module Described
end # module NRSER
