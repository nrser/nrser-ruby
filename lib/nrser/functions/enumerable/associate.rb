##
# Functions for associating entries in an {Enumerable} as key or values in
# a {Hash}.
##

module NRSER
  
  # @!group Enumerable Functions
  
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
  # @param [Enumerable<V>] enum
  #   Enumerable containing the values for the hash.
  # 
  # @param [Proc<(V)=>K>] block
  #   Block that maps `enum` values to their hash keys.
  # 
  # @return [Hash<K, V>]
  # 
  # @raise [NRSER::ConflictError]
  #   If two values map to the same key.
  # 
  def self.assoc_by enum, &block
    enum.each_with_object( {} ) { |element, result|
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
  
  
  # Create a {Hash} mapping the entries in `enum` to the value returned by
  # passing them through `&block`, raising on conflicts.
  # 
  # @param [Enumerable<ENTRY>] enum
  # 
  # @param [ :raise | :first_wins | :last_wins | Proc ] on_conflict
  #   What to do when there's a conflict mapping the entries into the hash.
  #   
  #   The names are meant to make some sense.
  # 
  # @param [Proc<(ENTRY)=>VALUE>] block
  #   The star of the show! Maps `ENTRY` from `enum` to `VALUE` for the
  #   resulting hash.
  # 
  # @return [Hash<ENTRY, VALUE>]
  # 
  # @raise [NRSER::ConflictError]
  #   If a conflict occurs and `on_conflict` is set to `:raise`.
  # 
  def self.assoc_to enum, on_conflict: :raise, &block
    enum.each_with_object( {} ) { |entry, hash|
      value = if hash.key? entry
        case on_conflict
        when :raise
          raise NRSER::ConflictError.new binding.erb <<-END
            Entry <%= entry %> appears more than once in `enum`
            
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
  
  
end # module NRSER
