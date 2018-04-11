# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------
require 'nrser/errors/nicer_error'


# Definitions
# =======================================================================

# Raised when a {NRSER::Types::Type} fails to load a value from a {String}
# (via it's `#from_s` method).
# 
# This is a {NRSER::NicerError}.
# 
class NRSER::Types::FromStringError < ::ArgumentError
  
  # Mixins
  # ==========================================================================
  
  # Make life better.
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
  
  # Construct a `FromStringError`.
  # 
  # @param *message (see NRSER::NicerError#initialize)
  # 
  # @param [String] string:
  #   The string the type was trying to load a value from.
  # 
  # @param [NRSER::Types::Type] type:
  #   The type that was trying to load.
  # 
  # @param **kwds
  #   See {NRSER::NicerError#initialize}
  # 
  def initialize *message, string:, type:, **kwds
    @string = string
    @type = type
    
    super \
      *message,
      type: type,
      string: string,
      **kwds
  end
  
  
  # Main message to use when none provided to {#initialize}.
  # 
  # @return [String]
  # 
  def default_message
    ["Failed to load type", type.name, "from string", string.inspect]
  end
  
end # class NRSER::Types::TypeError
