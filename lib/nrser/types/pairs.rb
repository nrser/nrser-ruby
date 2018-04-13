# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------
require 'nrser/core_ext/hash'

require_relative './combinators'
require_relative './tuples'


# Refinements
# =======================================================================


# Declarations
# =======================================================================

module NRSER; end


# Definitions
# =======================================================================

module NRSER::Types
  
  # Type for key/value pairs encoded as a {.tuple} (Array) of length 2.
  # 
  def_factory(
    :array_pair,
  ) do |name: 'ArrayPair', key: any, value: any, **options|
    unless options.key? :name
      options[:name] = if key == any && value == any
        'ArrayPair'
      else
        key = NRSER::Types.make key
        value = NRSER::Types.make value
        
        "ArrayPair<#{ key.name }, #{ value.name }>"
      end
    end
    
    tuple \
      key,
      value,
      # name: name,
      **options
  end # .array_pair
  
  
  # Type for key/value pairs encoded as {Hash} with a single entry.
  # 
  # @param [String] name:
  #   Name to give the new type.
  # 
  # @param [Hash] **options
  #   Other options to pass to
  # 
  def_factory(
    :hash_pair,
  ) do |key: any, value: any, **options|
    unless options.key? :name
      options[:name] = if key == any && value == any
        'HashPair'
      else
        key = NRSER::Types.make key
        value = NRSER::Types.make value
        
        "HashPair<#{ key.name }, #{ value.name }>"
      end
    end
    
    intersection \
      hash_type( keys: key, values: value ),
      length( 1 ),
      # name: name,
      **options
  end # .hash_pair
  

  # A key/value pair, which can be encoded as an Array of length 2 or a
  # Hash of length 1.
  # 
  # 
  def_factory :pair do |key: any, value: any, **options|
    unless options.key? :name
      options[:name] = if key == any && value == any
        'Pair'
      else
        key = NRSER::Types.make key
        value = NRSER::Types.make value
        
        "Pair<#{ key.name }, #{ value.name }>"
      end
    end
    
    union \
      array_pair( key: key, value: value ),
      hash_pair( key: key, value: value ),
      **options
  end # #pair
  
end # module NRSER::Types
