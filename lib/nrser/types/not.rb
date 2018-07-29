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
      "#{ NOT }#{ @type.name }"
    end
    
  end # class Not
  
  
  def_factory(
    :not,
  ) do |type, **options|
    Not.new type, **options
  end
  
end # module NRSER::Types
