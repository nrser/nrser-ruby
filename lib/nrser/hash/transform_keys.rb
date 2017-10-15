module NRSER
  
  # Lifted from ActiveSupport.
  # 
  # @see http://www.rubydoc.info/gems/activesupport/5.1.3/Hash:transform_keys!
  # 
  # @param [Hash] hash
  #   Hash to mutate keys.
  # 
  # @return [Hash]
  #   The mutated hash.
  # 
  def self.transform_keys! hash
    # File 'lib/active_support/core_ext/hash/keys.rb', line 23
    hash.keys.each do |key|
      hash[yield(key)] = hash.delete(key)
    end
    hash
  end
  
  
  # Returns a new hash with each key transformed by the provided block.
  # 
  # Lifted from ActiveSupport.
  # 
  # @see http://www.rubydoc.info/gems/activesupport/5.1.3/Hash:transform_keys
  # 
  # @param [Hash] hash
  # 
  # @return [Hash]
  #   New hash with transformed keys.
  # 
  def self.transform_keys hash, &block
    # File 'lib/active_support/core_ext/hash/keys.rb', line 12
    result = {}
    hash.each_key do |key|
      result[yield(key)] = hash[key]
    end
    result
  end
  
  # My-style name
  singleton_class.send :alias_method, :map_keys, :transform_keys

end # module NRSER
