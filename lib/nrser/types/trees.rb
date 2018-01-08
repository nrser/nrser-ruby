# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------
require_relative './combinators'
require_relative './responds'
require_relative './is_a'


# Refinements
# =======================================================================

require 'nrser/refinements'
using NRSER


# Definitions
# =======================================================================

module NRSER::Types
  
  # @todo Document array_like method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.array_like **options
    if options.empty?
      ARRAY_LIKE
    else
      intersection \
        is_a( Enumerable ),
        respond_to( :each_index ),
        **options
    end
  end # .array_like
  
  ARRAY_LIKE = array_like( name: 'ArrayLikeType' ).freeze
  
  
  # @todo Document hash_like method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.hash_like **options
    if options.empty?
      HASH_LIKE
    else
      intersection \
        is_a( Enumerable ),
        respond_to( :each_pair ),
        **options
    end
  end # .hash_like
  
  HASH_LIKE = hash_like( name: 'HashLikeType' ).freeze
  
  
  # @todo Document tree method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.tree **options
    if options.empty?
      TREE
    else
      union \
        array_like,
        hash_like,
        **options
    end
  end # .tree
  
  TREE = tree( name: 'TreeType' ).freeze
  
end # module NRSER::Types
