# Definitions
# =======================================================================

module NRSER
  
  # @!group Hash Functions
  
  # Mutates `hash` by converting all keys that respond to `#to_sym` to symbols.
  # 
  # Lifted from ActiveSupport.
  # 
  # @see http://www.rubydoc.info/gems/activesupport/5.1.3/Hash:symbolize_keys!
  # 
  # @param [Hash] hash
  # 
  # @return [Hash]
  # 
  def self.symbolize_keys! hash
    transform_keys!(hash) { |key| key.to_sym rescue key }
  end # .symbolize_keys!
  
  singleton_class.send :alias_method, :to_sym_keys!, :symbolize_keys!
  
  
  # Returns a new hash with all keys that respond to `#to_sym` converted to
  # symbols.
  # 
  # Lifted from ActiveSupport.
  # 
  # @see http://www.rubydoc.info/gems/activesupport/5.1.3/Hash:symbolize_keys
  # 
  # @param [Hash] hash
  # 
  # @return [Hash]
  # 
  def self.symbolize_keys hash
    # File 'lib/active_support/core_ext/hash/keys.rb', line 54
    transform_keys(hash) { |key| key.to_sym rescue key }
  end
  
  singleton_class.send :alias_method, :to_sym_keys, :symbolize_keys
  
  
  # @todo Document deep_symbolize_keys method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.deep_symbolize_keys object, &block
    deep_transform_keys( object ) { |key| key.to_sym rescue key }
  end # .deep_symbolize_keys
  

end # module NRSER
