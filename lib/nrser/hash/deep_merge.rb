
# Definitions
# =======================================================================

module NRSER
  
  # Returns a new hash created by recursively merging `other_hash` on top of
  # `base_hash`.
  # 
  # Adapted from ActiveSupport.
  # 
  # @see https://github.com/rails/rails/blob/23c8f6918d4e6b9a823aa7a91377c6e3b5d60e13/activesupport/lib/active_support/core_ext/hash/deep_merge.rb
  # 
  # @param [Hash] base_hash
  #   Base hash - it's values will be overwritten by any key paths shared with 
  #   the other hash.
  # 
  # @param [Hash] other_hash
  #   "Update" hash - it's values will overwrite values at the same key path
  #   in the base hash.
  #   
  #   I don't love the name; just went with what ActiveSupport used.
  # 
  # @return [Hash]
  #   New merged hash.
  # 
  def self.deep_merge base_hash, other_hash, &block
    deep_merge! base_hash.dup, other_hash, &block
  end # .deep_merge
  
  
  # Same as {.deep_merge}, but modifies `base_hash`.
  # 
  # @return [Hash]
  #   The mutated base hash.
  # 
  def self.deep_merge! base_hash, other_hash, &block
    other_hash.each_pair do |current_key, other_value|
      this_value = base_hash[current_key]

      base_hash[current_key] = if this_value.is_a?(Hash) && 
                                  other_value.is_a?(Hash)
        deep_merge this_value, other_value, &block
      else
        if block_given? && base_hash.key?( current_key )
          block.call(current_key, this_value, other_value)
        else
          other_value
        end
      end
    end

    base_hash
  end
  
  
end # module NRSER
