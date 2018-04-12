# encoding: UTF-8
# frozen_string_literal: true


# Definitions
# =======================================================================

module NRSER::Types
  
  class Not < Type
    
    # Constructor
    # ======================================================================
    
    # Instantiate a new `NRSER::Types::Not`.
    def initialize type, **options
      super **options
      @type = type
    end # #initialize
    
    
    # Instance Methods
    # ======================================================================
    
    def test? value
      ! @type.test( value )
    end
    
    
    def explain
      "!#{ @type.name }"
    end
    
    
    # @return [String]
    #   a brief string description of the type - just it's {#name} surrounded
    #   by some back-ticks to make it easy to see where it starts and stops.
    # 
    def to_s
      "{ x ∉ #{ @type.name } }"
    end
    
    alias_method :inspect, :to_s
    
    
  end # class Not
  
  
  def self.not type, **options
    Not.new type, **options
  end
  
end # module NRSER::Types
