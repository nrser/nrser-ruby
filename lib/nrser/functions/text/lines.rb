module NRSER
  # @!group Text Functions
  
  # Classes
  # =====================================================================
  
  # @todo document Lines class.
  class Lines < Array
    
    # Constants
    # ======================================================================
    
    
    # Class Methods
    # ======================================================================
    
    
    # Attributes
    # ======================================================================
    
    
    # Constructor
    # ======================================================================
    
    # Instantiate a new `Lines`.
    def initialize
      
    end # #initialize
    
    
    # Instance Methods
    # ======================================================================
    
  end # class Lines
  
  
  # Functions
  # =====================================================================
  
  def self.lines text
    case text
    when String
      text.lines
    when Array
      text
    else
      raise TypeError,
        "Expected String or Array, found #{ text.class.safe_name }"
    end
  end
  
end # module NRSER
