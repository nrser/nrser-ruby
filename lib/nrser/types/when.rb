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
  
  class When < Type
    
    
    # The wrapped {Object} whose `#===` will be used to test membership.
    # 
    # @return [Object]
    #     
    attr_reader :object
    
    
    # Constructor
    # ======================================================================
    
    # Instantiate a new `NRSER::Types::When`.
    def initialize object, **options
      super **options
      @object = object
    end # #initialize
    
    
    # Instance Methods
    # ======================================================================
    
    def test value
      @object === value
    end
    
    
    def default_name
      @object.to_s
    end
    
    # If {#object} responds to `#from_data`, call that and check results.
    # 
    # Otherwise, forward up to {NRSER::Types::Type#from_data}.
    # 
    # @param [Object] data
    #   Data to create the value from that will satisfy the type.
    # 
    # @return [Object]
    #   Instance of {#object}.
    # 
    def from_data data
      if @from_data.nil?
        if @object.respond_to? :from_data
          check @object.from_data( data )
        else
          super data
        end
      else
        @from_data.call data
      end
    end
    
    
    def has_from_data?
      @from_data || @object.respond_to?( :from_data )
    end
    
    
    def == other
      equal?( other ) ||
      ( self.class == other.class &&
        self.object == other.object )
    end
    
  end # class When
  
  
  def self.when value, **options
    When.new value, **options
  end
  
end # module NRSER::Types
