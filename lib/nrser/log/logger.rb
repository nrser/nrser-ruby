# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------


# Refinements
# =======================================================================


# Declarations
# =======================================================================


# Definitions
# =======================================================================

# Extension of {SemanticLogger::Logger} to add and customize behavior.
# 
class NRSER::Log::Logger < SemanticLogger::Logger
  
  # Constants
  # ========================================================================
  
  
  # @todo document Catcher class.
  class Catcher
    
    # Constants
    # ========================================================================
    
    
    # Class Methods
    # ========================================================================
    
    
    # Attributes
    # ========================================================================
    
    
    # Constructor
    # ========================================================================
    
    # Instantiate a new `Catcher`.
    def initialize logger, on_fail: nil
      @logger = logger
      @on_fail = on_fail
    end # #initialize
    
    
    # Instance Methods
    # ========================================================================
    
    SemanticLogger::LEVELS.each do |level|
      define_method level do |message = nil, payload = nil, &block|
        begin
          block.call
        rescue Exception => error
          @logger.send level, message, payload, error
          @on_fail
        end
      end
    end
  end # class Catcher
  
  
  # Class Methods
  # ========================================================================
  
  
  # Attributes
  # ========================================================================
  
  
  # Constructor
  # ========================================================================
  
  
  # Instance Methods
  # ========================================================================
  
  
  # @todo Document catch method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def catch **options
    Catcher.new self, **options
  end # #catch
  
  
end # class NRSER::Log::Logger
