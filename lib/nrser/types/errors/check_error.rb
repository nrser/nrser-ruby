# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------
require 'nrser/errors/type_error'


# Definitions
# =======================================================================

# This error (or a subclass) is thrown when types fail to
# {NRSER::Types::Type.check!}.
# 
class NRSER::Types::CheckError < NRSER::TypeError
  
  # Attributes
  # ========================================================================
  
  # The type that was checked against.
  # 
  # @return [NRSER::Types::Type]
  #     
  attr_reader :type
  
  
  # The value that failed the type check.
  # 
  # @return [*]
  #     
  attr_reader :value
  
  
  # Constructor
  # ========================================================================
  
  # Construct a `NicerError`.
  # 
  # @param [*] value
  #   The {#value} that failed the check.
  # 
  # @param [NRSER::Types::Type] type
  #   The type that was checked.
  # 
  # @param details: (see NRSER::NicerError#initialize)
  # 
  # @param [Hash] kwds
  #   See {NRSER::NicerError#initialize}
  # 
  def initialize *message, value:, type:, details: nil, **kwds
    @value = value
    @type = type
    
    if details.is_a?( Proc ) && details.arity != 0
      orig_details = details
      details = -> { orig_details.call type: type, value: value }
    end
    
    super \
      *message,
      type: type,
      value: value,
      details: details,
      **kwds
  end
  
  
  # Build default message when none provided.
  # 
  # @return [String]
  # 
  def default_message
    ["Value", value.inspect, "failed check for type", type.name]
  end # #default_message
  
  
end # class NRSER::Types::TypeError
