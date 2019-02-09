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
  
  # @!attribute [r] type
  #   The type that was checked against.
  #   
  #   @return [NRSER::Types::Type]
  #     
  def_context_delegator keys: :type, presence_predicate: false
  
  
  # @!attribute [r] value
  #   The value that failed the type check.
  #   
  #   @return [::Object]
  #     
  def_context_delegator keys: :value, presence_predicate: false
  
  
  # Constructor
  # ========================================================================
  
  # Construct a `NicerError`.
  # 
  # @param [::Object] value
  #   The {#value} that failed the check.
  # 
  # @param [NRSER::Types::Type] type
  #   The type that was checked.
  # 
  # @param details (see NRSER::NicerError#initialize)
  # 
  # @param [Hash] kwds
  #   See {NRSER::NicerError#initialize}
  # 
  def initialize *message, value:, type:, details: nil, **kwds
    # TODO  What's up w this shit? 2019.02.10
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
