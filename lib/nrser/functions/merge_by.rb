module NRSER

  # Deep merge arrays of data hashes, matching hashes by computing a key with
  # `&merge_key`.
  # 
  # Uses {NRSER.deep_merge!} to merge.
  # 
  # @param [Array<Hash>] current
  #   Current (base) array of hashes to start with (lowest predominance).
  # 
  # @param [Array<Hash>] updates
  #   One or more arrays of update hashes to merge over `current` (last is
  #   highest predominance).
  # 
  # @param [Proc<(Hash)=>Object>] merge_key
  #   Each hash is passed to `&merge_key` and the result is used to match
  #   hashes for merge. Must not return equal values for two different hashes
  #   in any of the arrays (`current` or any of `*updates`).
  # 
  # @return [Array<Hash>]
  #   Final array of merged hashes. Don't depend on order.
  # 
  def self.merge_by current, *updates, &merge_key
    updates.reduce( assoc_by current, &merge_key ) { |result, update|
      result.deep_merge! assoc_by( update, &merge_key )
    }.values
  end # .merge_by
    
end # module NRSER
