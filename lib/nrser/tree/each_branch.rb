# Definitions
# =======================================================================

module NRSER
  
  # Enumerate over the immediate "branches" of a structure that can be used
  # to compose our idea of a *tree*: nested hash-like and array-like structures
  # like you would get from parsing a JSON document.
  # 
  # Written and tested against Hash and Array instances, but should work with
  # anything hash-like that responds to `#each_pair` appropriately or
  # array-like that responds to `#each_index` and `#each_with_index`.
  # 
  # @note Not sure what will happen if the tree has circular references!
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
  # @yieldreturn
  #   Ignored.
  # 
  # @return [Enumerator]
  #   If no block is provided.
  # 
  # @return [#each_pair | (#each_index & #each_with_index)]
  #   If a block is provided, the result of the `#each_pair` or
  #   `#each_with_index` call.
  # 
  # @raise [NoMethodError]
  #   If `tree` does not respond to `#each_pair` or to `#each_index` and 
  #   `#each_with_index`.
  # 
  def self.each_branch tree, &block
    if tree.respond_to? :each_pair
      # Hash-like
      tree.each_pair &block
      
    elsif tree.respond_to? :each_index
      # Array-like... we test for `each_index` because - unintuitively - 
      # `#each_with_index` is a method of {Enumerable}, meaning that {Set}
      # responds to it, though sets are unordered and the values can't be
      # accessed via those indexes. Hence we look for `#each_index`, which 
      # {Set} does not respond to.
      
      if block.nil?        
        index_enumerator = tree.each_with_index
        
        Enumerator.new( index_enumerator.size ) { |yielder|
          index_enumerator.each { |value, index|
            yielder.yield index, value
          }
        }
      else
        tree.each_with_index.map { |value, index|
          block.call index, value
        }
      end
      
    else
      raise NoMethodError.new NRSER.squish <<-END
        `tree` param must respond to `#each_pair` or `#each_index`,
        found #{ tree.inspect }
      END
      
    end # if / else
  end # .each_branch
  
end # module NRSER
