# frozen_string_literal: true
# encoding: UTF-8

# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require_relative './attr_error'


# Namespace
# ========================================================================

module  NRSER


# Definitions
# ========================================================================

# Raised when we expected `#count` to be something it's not.
# 
class NRSER::CountError < NRSER::AttrError

  # Create a new {CountError}.
  # 
  # @param [Array] message
  #   See {NicerError#initialize}.
  # 
  # @param [Hash<Symbol, Object>] kwds
  #   Except as called out below, other keywords are passed up to 
  #   {NicerError#initialize}.
  # 
  # @option kwds [Object] :value
  #   The value that has the bad `#count`.
  # 
  # @option kwds [Integer | NRSER::Types::Type | String] :expected
  #   Encouraged to be one of:
  #   
  #   1.  An exact {Integer} that you were looking for.
  #       
  #   2.  A {NRSER::Types::Type} satisfied by what you would have been satisfied
  #       with.
  #       
  #   3.  A {String} explanation of the condition.
  # 
  # @option kwds [Integer] :actual
  #   The actual count.
  # 
  def initialize *message, **kwds
    kwds[:actual] = kwds.delete( :count ) if kwds.key?( :count )
    super *message, **kwds, name: :count
  end

  # Alias for {#actual?}.
  def count?; actual?; end
  
  # Alias for {#actual}.
  def count; actual; end

end # class CountError


# /Namespace
# ========================================================================

end # module NRSER
