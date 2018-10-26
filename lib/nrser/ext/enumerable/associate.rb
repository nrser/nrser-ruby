# encoding: UTF-8
# frozen_string_literal: true

# Namespace
# ========================================================================

module NRSER
module Ext


# Definitions
# ========================================================================

# Methods for associating entries in an {Enumerable} as key or values in
# a {Hash}.
# 
module Enumerable
  
  # Convert an enumerable to a hash by passing each entry through `&block` to
  # get it's key, raising an error if multiple entries map to the same key.
  # 
  # @example Basic usage
  #   ['a', :b].assoc_by &:class
  #   # => {String=>"a", Symbol=>:b}
  # 
  # @example Conflict error
  #   [:a, :b].assoc_by &:class
  #   # NRSER::ConflictError: Key Symbol is already in results with value:
  #   # 
  #   #     :a
  #   #
  # 
  # @param [Proc<(V)=>K>] block
  #   Block that maps this {Enumerable}'s values to their hash keys.
  # 
  # @return [Hash<K, V>]
  # 
  # @raise [NRSER::ConflictError]
  #   If two values map to the same key.
  # 
  def assoc_by &block
    each_with_object( {} ) { |element, result|
      key = block.call element
      
      if result.key? key
        raise NRSER::ConflictError.new binding.erb <<-END
          Key <%= key.inspect %> is already in results with value:
          
              <%= result[key].pretty_inspect %>
          
        END
      end
      
      result[key] = element
    }
  end # .assoc_by
  
  
  # Create a {Hash} mapping the entries in this {Enumerable} to the value
  # returned by passing them through `&block`, raising on conflicts.
  # 
  # @param [ :raise | :first_wins | :last_wins | Proc ] on_conflict
  #   What to do when there's a conflict mapping the entries into the hash.
  #   
  #   The names are meant to make some sense.
  # 
  # @param [Proc<(ENTRY)=>VALUE>] block
  #   The star of the show! Maps `ENTRY` from this {Enumerable} to its `VALUE`
  #   in the resulting hash.
  # 
  # @return [Hash<ENTRY, VALUE>]
  # 
  # @raise [NRSER::ConflictError]
  #   If a conflict occurs and `on_conflict` is set to `:raise`.
  # 
  def assoc_to on_conflict: :raise, &block
    each_with_object( {} ) { |entry, hash|
      value = if hash.key? entry
        case on_conflict
        when :raise
          raise NRSER::ConflictError.new binding.erb <<-END
            Entry <%= entry %> appears more than once in {Enumerable}
            
            This would cause conflict in the resulting {Hash}.
            
            Entry:
            
                <%= entry.pretty_inspect %>
            
          END
        when :first_wins
          # do nothing
        when :last_wins
          hash[entry] = block.call entry
        when Proc
          hash[entry] = on_conflict.call \
            entry: entry,
            current_value: hash[entry],
            block: block
        else
          raise ArgumentError,
            "Bad `on_conflict`: #{ on_conflict.inspect }"
        end
      else
        block.call entry
      end
      
      hash[entry] = value
    }
  end # .assoc_to
  
  # @!endgroup Associating Instance Methods # ********************************
  
end # module Enumerable


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
