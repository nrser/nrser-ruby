# Definitions
# =======================================================================

module NRSER
  
  # @!group Hash Functions

  # Lifted from ActiveSupport.
  # 
  # @see http://www.rubydoc.info/gems/activesupport/5.1.3/Hash:slice
  # 
  # 
  def self.slice_keys hash, *keys
    # We're not using this, but, whatever, leave it in...
    if hash.respond_to?(:convert_key, true)
      keys.map! { |key| hash.send :convert_key, key }
    end
    
    keys.each_with_object(hash.class.new) { |k, new_hash|
      new_hash[k] = hash[k] if hash.has_key?(k)
    }
  end
  
  
  # Meant to be a drop-in replacement for the ActiveSupport version, though
  # I've changed the implementation a bit... because honestly I didn't
  # understand why they were doing it the way they do :/
  # 
  # @see http://www.rubydoc.info/gems/activesupport/5.1.3/Hash:slice!
  # 
  # 
  def self.slice_keys! hash, *keys
    # We're not using this, but, whatever, leave it in...
    if hash.respond_to?(:convert_key, true)
      keys.map! { |key| hash.send :convert_key, key }
    end
    
    slice_keys( hash, *keys ).tap { |slice|
      except_keys! hash, *keys
    }
  end

end # module NRSER
