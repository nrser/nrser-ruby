# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------
require 'nrser/errors/nicer_error'


# Definitions
# =======================================================================

# @todo doc me!
# 
class NRSER::Types::FromStringError < ::ArgumentError
  
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
  
  
  # The string we were trying to load from.
  # 
  # @return [String]
  #     
  attr_reader :string
  
  
  # Constructor
  # ========================================================================
  
  def initialize *message, string:, type:, **kwds
    
    @string = string
    @type = type
    
    if message.empty?
      message = ["Failed to load type", type.name, "from string", string]
    end
    
    super \
      *message,
      type: type,
      string: string,
      **kwds
  end
  
end # class NRSER::Types::TypeError
