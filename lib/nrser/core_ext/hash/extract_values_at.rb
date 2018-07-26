class Hash  
  # Like {#extract!} combined with {Hash#values_at} - extracts `keys` and
  # appends (via `#<<`) the values to `into` (in order of `keys`).
  # 
  # `into` default to an empty Array.
  # 
  # @example Basic Usage
  #   hash = { a: 1, b: 2, c: 3, d: 4 }
  #   
  #   hash.extract_values_at! :a, :b
  #   # => [1, 2]
  #   
  #   hash
  #   # => {c: 3, d: 4}
  #   
  #   hash = { a: 1, b: 2, c: 3, d: 4 }
  #   
  #   hash.extract_values_at! :b, :a
  #   # => [2, 1]
  # 
  #   hash
  #   # => {c: 3, d: 4}
  #   
  # @example Custom `into
  #   hash = { a: 1, b: 2, c: 3, d: 4 }
  #   into = Set[1, 3, 5]
  # 
  #   hash.extract_values_at! :a, :b, into: into
  #   # => #<Set: {1, 3, 5, 2}>
  #   
  #   hash
  #   # => {:c=>3, :d=>4}
  #   
  # @param *keys
  #   Hash keys to extract.
  # 
  # @param [#<<] into
  #   Object to extract values at `keys` into.
  # 
  # @return [into]
  #   The `into` object with the extracted values (if any are found).
  # 
  def extract_values_at! *keys, into: []
    keys.each_with_object( into ) { |key, result|
      result << delete(key) if has_key?( key )
    }
  end
  
end
