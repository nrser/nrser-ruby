# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

# Need {NRSER::Ext::Enumerable::Associate#assoc_by}
require_relative './associate'


# Namespace
# ========================================================================

module NRSER
module Ext


# Definitions
# ========================================================================

module Enumerable

  # Deep merge arrays of data hashes, matching hashes by computing a key with
  # `&merge_key`.
  # 
  # Uses {NRSER.deep_merge!} to merge.
  # 
  # @example Merging hashes by an `:id` value
  #   
  #   data = [
  #     { id: 1, name: 'Mica' },
  #     { id: 2, name: 'Hudie' }
  #   ]
  #   
  #   update = [
  #     { id: 1, is_a: 'American' },
  #     { id: 2, is_a: 'American Shorthair' },
  #   ]
  # 
  #   data.n_x.merge_by( update ) { |entry| entry[ :id ] }
  #   #=> [
  #     { id: 1, name: 'Mica', is_a: 'American' },
  #     { id: 2, name: 'Hudie', is_a: 'American Shorthair' },  
  #   ]
  # 
  # @param [Array<Hash>] updates
  #   One or more {Enumerable}s of update hashes to merge over `current` (last 
  #   is highest predominance).
  # 
  # @param [Proc<(Hash)=>Object>] merge_key
  #   Each hash is passed to `&merge_key` and the result is used to match
  #   hashes for merge. Must not return equal values for two different hashes
  #   in any of the arrays (`current` or any of `*updates`).
  # 
  # @return [Array<Hash>]
  #   Final array of merged hashes. Don't depend on order.
  # 
  def merge_by *updates, &merge_key
    updates.reduce( assoc_by &merge_key ) { |result, update|
      result.deep_merge! update.n_x.assoc_by( &merge_key )
    }.values
  end # #merge_by
    
end # module Enumerable


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
