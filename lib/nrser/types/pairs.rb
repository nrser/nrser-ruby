# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------
require_relative './combinators'


# Refinements
# =======================================================================


# Declarations
# =======================================================================

module NRSER; end


# Definitions
# =======================================================================

module NRSER::Types
  
  
  # @todo Document array_pair method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.array_pair **options
    return ARRAY_PAIR if options.empty?
    
    key   = options.delete(:key)    || ANY
    value = options.delete(:value)  || ANY
    
    tuple key, value, **options
  end # .array_pair
  
  ARRAY_PAIR = array_pair( name: 'ArrayPairType' ).freeze
  
  
  # Type for a {Hash} that consists of only a single key and value pair.
  # 
  # @param [String] name:
  #   Name to give the new type.
  # 
  # @param [Hash] **options
  #   Other options to pass to 
  # 
  # @return [NRSER::Types::Type]
  # 
  def self.hash_pair **options
    return HASH_PAIR if options.empty?
    
    hash_options = {}
    {key: :keys, value: :values}.each { |from_key, to_key|
      if options.key? from_key
        hash_options[to_key] = options.delete from_key
      end
    }
    
    if hash_options.empty?
      intersection is_a( Hash ), length( 1 ), **options
    else    
      intersection \
        hash_type( **hash_options ),
        length( 1 ),
        **options
    end
    
  end # .hash_pair
  
  HASH_PAIR = hash_pair( name: 'HashPairType' ).freeze
  

  # @todo Document pair method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.pair **options
    if options.empty?
      PAIR
    else
      type_options = NRSER.slice_keys options, :key, :value
      
      union \
        array_pair( **type_options ),
        hash_pair( **type_options ),
        **options
    end
  end # #pair
  
  PAIR = pair( name: 'PairType' ).freeze
  
end # module NRSER::Types

