# Definitions
# =======================================================================

module NRSER
  
  # @!group Hash Functions
  
  # Removes the given keys from hash and returns it.
  # 
  # Lifted from ActiveSupport.
  # 
  # @see http://www.rubydoc.info/gems/activesupport/5.1.3/Hash:except!
  # 
  # @param [Hash] hash
  #   Hash to mutate.
  # 
  # @return [Hash]
  # 
  def self.except_keys! hash, *keys
    keys.each { |key| hash.delete(key) }
    hash
  end
  
  singleton_class.send :alias_method, :omit_keys!, :except_keys!
  
  
  # Returns a new hash without `keys`.
  # 
  # Lifted from ActiveSupport.
  # 
  # @see http://www.rubydoc.info/gems/activesupport/5.1.3/Hash:except
  # 
  # @param [Hash] hash
  #   Source hash.
  # 
  # @return [Hash]
  # 
  def self.except_keys hash, *keys
    except_keys! hash.dup, *keys
  end
  
  singleton_class.send :alias_method, :omit_keys, :except_keys

end # module NRSER
