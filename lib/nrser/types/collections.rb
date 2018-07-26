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
  
  
  def_factory(
    :map,
    aliases: [ :assoc, :hash_like ],
   ) do |name: 'Map', **options|
    intersection \
      is_a( Enumerable ),
      respond_to( :each_pair ),
      name: name,
      **options
  end # .map


  def_factory(
    :bag,
  ) do |name: 'Bag', **options|
    intersection \
      is_a( Enumerable ),
      self.not( respond_to( :each_pair ) ),
      name: name,
      **options
  end
  
  
  def_factory :tree do |name: 'Tree', **options|
    union \
      array_like,
      hash_like,
      name: name,
      **options
  end # .tree
  
end # module NRSER::Types
