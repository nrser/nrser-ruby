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

module NRSER
  # Structure to hold an update, which consists of
  # 
  # -   A `:message` of type {NRSER::Message} that was sent to the previous
  #     value to produce the new one.
  # 
  # -   A `:response` that was received
  # 
  HistoryUpdate = Struct.new :message, :response
  
  class History < BasicObject
    
    # Constants
    # ======================================================================
    
    
    # Class Methods
    # ======================================================================
    
    
    # Attributes
    # ======================================================================
    
    
    # Constructor
    # ======================================================================
    
    # Instantiate a new `NRSER::History`.
    def initialize genesis
      @genesis = genesis
      @updates = []
      @current = genesis
    end # #initialize
    
    
    # Instance Methods
    # ======================================================================
    
    
    private
    # ========================================================================
      
      def method_missing method, *args, &block
        message = ::NRSER::Message.new method, *args, &block
        @current = message.send_to @current
        @updates << ::NRSER::HistoryUpdate.new \
          message: message,
          response: @current
      end
      
    # end private
    
    
    
  end # class NRSER::History
end # module NRSER

# Post-Processing
# =======================================================================
