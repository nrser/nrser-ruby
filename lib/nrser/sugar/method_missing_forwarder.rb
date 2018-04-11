# encoding: UTF-8
# frozen_string_literal: true

# Declarations
# =======================================================================

module NRSER; end


# Definitions
# ========================================================================

# A very simple class that forwards all method calls to the block it was
# initialized with (via {#method_missing}).
# 
class NRSER::MethodMissingForwarder < BasicObject
  
  # Constructor
  # ========================================================================
  
  # Instantiate a new `NRSER::MethodMissingForwarder` holding the forwarding
  # block.
  # 
  # @param [Proc<(symbol:Symbol, *args, &block)>] &forwarder
  #   Block that will receive all calls to {#method_missing}.
  # 
  def initialize &forwarder
    @forwarder = forwarder
  end # #initialize
  
  
  # Instance Methods
  # ========================================================================
  
  # Forwards all params to the `@forwarder` proc.
  # 
  # @param [Symbol] symbol
  #   The name of the method that was called.
  # 
  # @param [Array] *args
  #   Any parameters the missing method was called with.
  # 
  # @param [Proc?] &block
  #   The block the method was called with, if any.
  # 
  def method_missing symbol, *args, &block
    @forwarder.call symbol, *args, &block
  end
  
end # class NRSER::MethodMisser
