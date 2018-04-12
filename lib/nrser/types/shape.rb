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

module NRSER::Types
  
  class Shape < Type
    
    # Constructor
    # ======================================================================
    
    # Instantiate a new `NRSER::Types::Shape`.
    def initialize pairs, **options
      super **options
      @pairs = pairs.map { |k, v|
        [k, NRSER::Types.make( v )]
      }.to_h
    end # #initialize
    
    
    # Instance Methods
    # ======================================================================
    
    def test? value
      begin
        @pairs.all? { |k, v|
          v === value[k]
        }
      rescue
        false
      end
    end
    
    def explain
      inner = @pairs.map { |k, v|
        "[#{ k.inspect }]→#{ v.name }"
      }.join( ", " )
      
      if @pairs.count == 1
        inner
      else
        '(' + inner + ')'
      end
    end
    
  end # class Shape
  
  
  def self.shape pairs, **options
    Shape.new pairs, **options
  end
  
end # module NRSER::Types
