# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

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

# A Cucumber step component that consist of a single Cucumber expression 
# fragment.
# 
class Expression < Base
  
  module Types
    Transformer = t.IsA( ::Proc ) & t.Attributes( arity: t.PositiveInteger )
  end
  
  
  # Config
  # ============================================================================
  
  pretty_print_config \
    ivars: {
      mode: :defined,
      except: {
        :@transform_args_type => :never,
      }
    }
  
  
  # Attributes
  # ==========================================================================

  # Optional transformer {::Proc} to pass Cucumber parameter values for the 
  # expression through before delivering to the actual step block.
  # 
  # @return [nil | λ(*::Array)⟶::Array]
  #   Returned {::Array} **must** be the same length as the number of arguments.
  #     
  attr_reader :transformer
  
  
  # The type of both the arguments *and* respond to {#transform}.
  # 
  # @return [::NRSER::Types::Type]
  # 
  attr_reader :transform_args_type
  
  
  def initialize name, expression, &transformer
    super( name )
    @expression = expression.to_s
    @transformer = Types::Transformer.check! transformer
    @transform_args_type = t.Array & t.Length( arity )
  end
  
  
  def arity
    transformer.arity
  end
  
  
  def transform *args
    transform_args_type.check! args
    
    if transformer
      transform_args_type.check! transformer.call( *args )
    else
      args
    end
  end
  
  
  def each &block
    return enum_for( __method__ ) unless block
    
    block.call [ self ]
    self
  end
  
end # class Expression


# /Namespace
# =======================================================================

end # module StepComponent
end # module Cucumber
end # module Described
end # module NRSER
