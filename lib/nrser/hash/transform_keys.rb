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
  
  # My-style names
  singleton_class.send :alias_method, :map_keys,  :transform_keys
  singleton_class.send :alias_method, :rekey,     :transform_keys
  
  
  # Deeply transform Hash keys that we can find by traversing Hash and Array
  # instances that we can find from `object` and piping keys through `block`.
  # 
  # @example Hash top node
  #   
  #   NRSER.deep_transform_keys({
  #     people: {
  #       jane: {fav_color: 'red'},
  #       joe:  {fav_color: 'blue'},
  #     }
  #   }) { |key| key.to_s.upcase }
  #   # => {
  #   # "PEOPLE" => {
  #   #   "JANE" => {"FAV_COLOR" => 'red'},
  #   #   "JOE"  => {"FAV_COLOR" => 'blue'},
  #   # }
  # 
  # @example Array top node
  #   
  #   NRSER.deep_transform_keys(
  #     [{x: 2}, {y: 'blue'}, 3]
  #   ) { |key| key.to_s.upcase }
  #   # => [{'X' => 2}, {'Y' => 'blue'}, 3]
  # 
  # 
  # @example Non-array or hash value
  #   
  #   NRSER.deep_transform_keys 'blah'
  #   # => 'blah'
  # 
  # From ActiveSupport.
  # 
  # @see http://www.rubydoc.info/gems/activesupport/5.1.3/Hash:deep_transform_keys
  # 
  # @todo Maybe this is a tree function?
  # 
  # @param [Object] object
  #   Anything; see examples.
  # 
  # @param [Proc] &block
  #   Proc that should accept each key as it's only argument and return the 
  #   new key to replace it with.
  # 
  def self.deep_transform_keys object, &block
    case object
    when Hash
      object.each_with_object( {} ) do |(key, value), result|
        result[block.call( key )] = deep_transform_keys value, &block
      end
    when Array
      object.map { |entry| deep_transform_keys entry, &block }
    else
      object
    end
  end
  
  singleton_class.send :alias_method, :deep_map_keys, :deep_transform_keys
  singleton_class.send :alias_method, :map_keys_r,    :deep_transform_keys
  singleton_class.send :alias_method, :deep_rekey,    :deep_transform_keys
  singleton_class.send :alias_method, :rekey_r,       :deep_transform_keys
  
  
  # Like {NRSER.deep_transform_keys} but mutates the objects (works in place).
  # 
  # @param object (see NRSER.deep_transform_keys)
  # @param &block (see NRSER.deep_transform_keys)
  # 
  # @return [Object]
  #   The `object` that was passed in, post mutations.
  # 
  def self.deep_transform_keys! object, &block
    case object
    when Hash
      object.keys.each do |key|
        value = object.delete key
        object[block.call( key )] = deep_transform_keys! value, &block
      end
      object
    when Array
      object.map! {|e| deep_transform_keys!(e, &block)}
    else
      object
    end
  end
  
  singleton_class.send :alias_method, :deep_map_keys!, :deep_transform_keys!
  singleton_class.send :alias_method, :map_keys_r!,    :deep_transform_keys!
  singleton_class.send :alias_method, :deep_rekey!,    :deep_transform_keys!
  singleton_class.send :alias_method, :rekey_r!,       :deep_transform_keys!
  

end # module NRSER
