# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------
require_relative './arrays'



# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# ========================================================================

# Tuple type - array of fixed length and types (though those could be
# {.Top}).
# 
# @note
#   Construct {Tuple} types using the {.Tuple} factory.
# 
class Tuple < ArrayType
  
  # Attributes
  # ======================================================================
  
  # The types of each of the tuple indexes.
  # 
  # @return [Array<Type>]
  #     
  attr_reader :types
  
  
  # Constructor
  # ======================================================================
  
  # Instantiate a new `Tuple`.
  # 
  # @param [Array] types
  #   Tuple value types by their index in the tuples.
  #   
  #   Entries are passed through {NRSER::Types.make} to create the type
  #   if needed.
  # 
  # @param [Hash<Symbol, *>] options
  #   Type options; see {Type#initialize}.
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
  #   See {Type#explain}
  # 
  def explain
    'Array<(' + types.map( &:explain ).join( ', ' ) + ')>'
  end
  
  
  # Instance Methods
  # ======================================================================
  
  # Test value for membership.
  # 
  # @param  (see Type#test?)
  # @return (see Type#test?)
  # @raise  (see Type#test?)
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
  # {ArrayType#from_s} by passing each value to `#from_s` in
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
  
end # class Tuple


#@!method self.Tuple *types, **options
#   Get a {Tuple} type.
#   
#   @param [Array<TYPE>] types
#     The types of the tuple values, in order they will appear. If entries are
#     not {Type} instances, they will be {.make} into them.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Tuple]
#   
def_type        :Tuple,
  default_name: false,
  parameterize: :types,
&->( *types, **options ) do
  Tuple.new *types, **options
end # .Tuple


# /Namespace
# ========================================================================

end # module Types
end # module NRSER
