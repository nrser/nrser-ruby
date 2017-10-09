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

require 'nrser/refinements'
using NRSER


# Declarations
# =======================================================================


# Definitions
# =======================================================================

module NRSER::Types
  
  # 
  class TupleType < NRSER::Types::ArrayType
    
    # Constants
    # ======================================================================
    
    
    # Class Methods
    # ======================================================================
    
    
    # Attributes
    # ======================================================================
    
    
    # Constructor
    # ======================================================================
    
    # Instantiate a new `TupleType`.
    def initialize *types, **options
      super **options
      @types = types.map &NRSER::Types.method(:make)
    end # #initialize
    
    
    # Instance Methods
    # ======================================================================
    
    # @todo Document test method.
    # 
    # @param [type] arg_name
    #   @todo Add name param description.
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def test value
      # Test the super class first
      return false unless super( value )
      
      # If it's not the right length then it doesn't pass
      return false unless value.length == @types.length
      
      # Test each item type
      @types.each_with_index.all? { |type, index|
        type.test value[index]
      }
    end # #test
    
  end # class TupleType
  

  # @todo Document tuple method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.tuple *types, **options
    TupleType.new *types, **options
  end # .tuple
  
end # module NRSER::Types


# Post-Processing
# =======================================================================
