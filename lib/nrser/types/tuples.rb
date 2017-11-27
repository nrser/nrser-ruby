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


# Definitions
# =======================================================================

module NRSER::Types
  
  # Tuple type - array of fixed length and types (though those could be
  # {NRSER::Types::ANY}).
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
    
    
    def default_name
      '[' + @types.map( &:name ).join( ', ' ) + ']'
    end
    
    
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
    
    
    # @return [Boolean]
    #   `true` if this type can load values from a string, which is true if
    #   *all* it's types can load values from strings.
    # 
    def has_from_s?
      @types.all? &:has_from_s?
    end # #has_from_s?
    
    
    # Load each value in an array of strings split out by
    # {NRSER::Types::ArrayType#from_s} by passing each value to `#from_s` in
    # the type of the corresponding index.
    # 
    # @param [Array<String>] strings
    # 
    # @return [Array]
    # 
    def items_from_strings strings
      @types.each_with_index.map { |type, index|
        type.from_s strings[index]
      }
    end
    
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
