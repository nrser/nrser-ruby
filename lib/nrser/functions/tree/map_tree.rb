module NRSER
  # Recursively descend through a tree mapping *all* non-structural elements
  # - anything not {NRSER::Types.hash_like} or {NRSER::Types.array_like}, both
  # hash keys *and* values, as well as array entries - through `block` to
  # produce a new structure.
  # 
  # Useful when you want to translate pieces of a tree structure depending on
  # their type or some other property that can be determined *from the element
  # alone* - `block` receives only the value as an argument, no location
  # information (because it's weirder to represent for keys and I didn't need
  # it for the {NRSER.transformer} stuff this was written for).
  # 
  # @note
  #   Array indexes **are not mapped** through `block` and can not be changed
  #   via this method. This makes it easier to do things like "convert all the
  #   integers to strings" when you mean the data entries, not the array
  #   indexes (which would fail since the new array wouldn't accept string
  #   indices).
  #   
  #   If you don't want to map hash keys use {NRSER.map_leaves}.
  # 
  # See the specs for examples. Used in {NRSER.transformer}.
  # 
  # @param tree (see NRSER.each_branch)
  # 
  # @param [Boolean] prune
  #   When `true`, prunes out values whose labels end with `?` and values are
  #   `nil`.
  # 
  # @yieldparam [Object] element
  #   Anything reached from the root that is not structural (hash-like or
  #   array-like), including / inside hash keys (though array
  #   indexes are **not** passed).
  # 
  def self.map_tree tree, prune: false, &block
    # TODO type check tree?
    
    mapped = tree.map { |element|
      # Recur if `element` is a tree.
      # 
      # Since `element` will be an {Array} of `key`, `value` when `tree` is a
      # {Hash} (or similar), this will descend into hash keys that are also
      # trees, as well as into hash values and array entries.
      # 
      if Types.tree.test element
        map_tree element, prune: prune, &block
      else
        # When we've run out of trees, finally pipe through the block:
        block.call element
      end
    }
    
    # If `tree` is hash-like, we want to convert the array of pair arrays
    # back into a hash.
    if Types.hash_like.test tree
      if prune
        pruned = {}
        
        mapped.each { |key, value|
          if  Types.Label.test( key ) &&
              key.to_s.end_with?( '?' )
            unless value.nil?
              new_key = key.to_s[0..-2]
              
              if key.is_a?( Symbol )
                new_key = new_key.to_sym
              end
              
              pruned[new_key] = value
            end
          else
            pruned[key] = value
          end
        }
        
        pruned
      else
        mapped.to_h
      end
    else
      # Getting here means it was array-like, so it's already fine
      mapped
    end
  end # .map_branches
  
end # module NRSER
