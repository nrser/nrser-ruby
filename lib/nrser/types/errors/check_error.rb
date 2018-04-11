# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------
require 'nrser/errors/nicer_error'


# Definitions
# =======================================================================

# This error (or a subclass) is thrown when types fail to
# {NRSER::Types::Type.check!}.
# 
class NRSER::Types::CheckError < ::TypeError
  
  # Mixins
  # ==========================================================================
  
  include NRSER::NicerError
  
  
  # Attributes
  # ========================================================================
  
  # The type that was checked against.
  # 
  # @return [NRSER::Types::Type]
  #     
  attr_reader :type
  
  
  # The value that failed the type check.
  # 
  # @return [attr_type]
  #     
  attr_reader :value
  
  
  # Constructor
  # ========================================================================
  
  def initialize value:, type:, details: nil, **kwds
    @value = value
    @type = type
    
    if details.is_a?( Proc ) && details.arity != 0
      orig_details = details
      details = -> { orig_details.call type: type, value: value }
    end
    
    super \
      "Value", value, "failed check for type", type.name,
      type: type,
      value: value,
      details: details,
      **kwds
  end
  
end # class NRSER::Types::TypeError
