# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------
require 'nrser/types/trees'


# Definitions
# =======================================================================

module NRSER
  
  # Map the immediate "branches" of a structure that can be used
  # to compose our idea of a *tree*: nested hash-like and array-like structures
  # like you would get from parsing a JSON document.
  # 
  # The `block` **MUST** return a pair ({Array} of length 2), the first value
  # of which is the key or index in the new {Hash} or {Array}.
  # 
  # These pairs are then converted into a {Hash} or {Array} depending on it 
  # `tree` was {NRSER::Types.hash_like} or {NRSER::Types.array_like}, and 
  # that value is returned.
  # 
  # Uses {NRSER.each_branch} internally.
  # 
  # Written and tested against Hash and Array instances, but should work with
  # anything:
  # 
  # 1.  *hash-like* that responds to `#each_pair` appropriately.
  # 
  # 2.  *array-like* that responds to `#each_index` and `#each_with_index`
  #     appropriately.
  # 
  # @note Not sure what will happen if the tree has circular references!
  # 
  # @todo
  #   Might be nice to have an option to preserve the tree class that creates
  #   a new instance of *whatever* it was and populates that, though I could 
  #   see this relying on problematic assumptions and producing confusing
  #   results depending on the actual classes.
  #   
  #   Maybe this could be encoded in a mixin that we would detect or something.
  # 
  # @example
  #   
  #   
  # 
  # @param [#each_pair | (#each_index & #each_with_index)] tree
  #   Structure representing a tree via hash-like and array-like containers.
  # 
  # @yieldparam [Object] key
  #   The first yielded param is the key or index for the value branch at the
  #   top level of `tree`.
  #   
  # @yieldparam [Object] value
  #   The second yielded param is the branch at the key or index at the top
  #   level of `tree`.
  # 
  # @yieldreturn [Array]
  #   Pair of key (/index) in new array or hash followed by value.
  # 
  # @return [Array | Hash]
  #   If no block is provided.
  # 
  # @raise [NoMethodError]
  #   If `tree` does not respond to `#each_pair` or to `#each_index` and 
  #   `#each_with_index`.
  # 
  def self.map_branches tree, &block
    if block.nil?
      raise ArgumentError, "Must provide block"
    end
    
    pairs = NRSER.each_branch( tree ).map &block
    
    NRSER::Types.match tree,
      NRSER::Types.hash_like, ->( _ ) {
        pairs.to_h
      },
      
      NRSER::Types.array_like, ->( _ ) {
        pairs.each_with_object( [] ) { |(index, value), array|
          array[index] = value
        }
      }
  end # .map_branches
  
end # module NRSER
