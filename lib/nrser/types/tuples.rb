# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------
require_relative './arrays'


# Definitions
# =======================================================================

module NRSER::Types
  
  # Tuple type - array of fixed length and types (though those could be
  # {Top}).
  # 
  class TupleType < NRSER::Types::ArrayType
    
    # Attributes
    # ======================================================================
    
    # The types of each of the tuple indexes.
    # 
    # @return [Array<NRSER::Types::Type>]
    #     
    attr_reader :types
    
    
    # Constructor
    # ======================================================================
    
    # Instantiate a new `TupleType`.
    # 
    # @param [Array] types
    #   Tuple value types by their index in the tuples.
    #   
    #   Entries are passed through {NRSER::Types.make} to create the type
    #   if needed.
    # 
    # @param [Hash<Symbol, *>] options
    #   Type options; see {NRSER::Types::Type#initialize}.
    # 
    def initialize *types, **options
      super **options
      @types = types.map( &NRSER::Types.method(:make) ).freeze
    end # #initialize


    def default_name
      'Array<(' + types.map( &:name ).join( ', ' ) + ')>'
    end


    def default_symbolic
      '[' + types.map( &:symbolic ).join( ', ' ) + ']'
    end
    
    
    # @return [String]
    #   See {NRSER::Types::Type#explain}
    # 
    def explain
      'Array<(' + types.map( &:explain ).join( ', ' ) + ')>'
    end
    
    
    # Instance Methods
    # ======================================================================
    
    # Test value for membership.
    # 
    # @param  (see NRSER::Types::Type#test?)
    # @return (see NRSER::Types::Type#test?)
    # @raise  (see NRSER::Types::Type#test?)
    # 
    def test? value
      # Test the super class first
      return false unless super( value )
      
      # If it's not the right length then it doesn't pass
      return false unless value.length == types.length
      
      # Test each item type
      types.each_with_index.all? { |type, index|
        type.test value[index]
      }
    end # #test?
    
    
    # @return [Boolean]
    #   `true` if this type can load values from a string, which is true if
    #   *all* it's types can load values from strings.
    # 
    def has_from_s?
      @from_s || types.all?( &:has_from_s? )
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
      types.each_with_index.map { |type, index|
        type.from_s strings[index]
      }
    end
    
  end # class TupleType
  

  # Get a tuple type.
  # 
  # @param *types (see TupleType#initialize)
  # @param [Hash] options (see TupleType#initialize)
  # 
  # @return [NRSER::Types::Type]
  # 
  def_factory :tuple do |*types, **options|
    TupleType.new *types, **options
  end # .tuple
  
end # module NRSER::Types
