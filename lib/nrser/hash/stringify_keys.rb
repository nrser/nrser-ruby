# Definitions
# =======================================================================

module NRSER
  
  # Converts all keys into strings by calling `#to_s` on them. **Mutates the
  # hash.**
  # 
  # Lifted from ActiveSupport.
  # 
  # @param [Hash] hash
  # 
  # @return [Hash<String, *>]
  # 
  def self.stringify_keys! hash
    transform_keys! hash, &:to_s
  end
  
  singleton_class.send :alias_method, :to_s_keys!, :stringify_keys!
  
  
  # Returns a new hash with all keys transformed to strings by calling `#to_s`
  # on them.
  # 
  # Lifted from ActiveSupport.
  # 
  # @param [Hash] hash
  # 
  # @return [Hash<String, *>]
  # 
  def self.stringify_keys hash
    transform_keys hash, &:to_s
  end
  
  singleton_class.send :alias_method, :to_s_keys, :stringify_keys
  
  
  # @todo Document deep_stringify_keys method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.deep_stringify_keys object
    deep_transform_keys object, &:to_s
  end # .deep_stringify_keys
  
  singleton_class.send :alias_method, :to_s_keys_r, :deep_stringify_keys
  

end # module NRSER
