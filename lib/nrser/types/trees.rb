# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------
require_relative './combinators'
require_relative './responds'
require_relative './is_a'


# Definitions
# =======================================================================

module NRSER::Types
  
  def_factory :array_like do |name: 'ArrayLike', **options|
    intersection \
      is_a( Enumerable ),
      respond_to( :each_index ),
      name: name,
      **options
  end # .array_like
  
  
  def_factory :hash_like do |name: 'HashLike', **options|
    intersection \
      is_a( Enumerable ),
      respond_to( :each_pair ),
      name: name,
      **options
  end # .hash_like
  
  
  def_factory :tree do |name: 'Tree', **options|
    union \
      array_like,
      hash_like,
      name: name,
      **options
  end # .tree
  
end # module NRSER::Types
