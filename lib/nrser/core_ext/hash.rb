require 'active_support/core_ext/hash'

require 'nrser/ext/tree'

require_relative './hash/extract_values_at'
require_relative './hash/transform_values_with_keys'

class Hash
  include NRSER::Ext::Tree
  
  # Short names
  # 
  # NOTE  If we use `alias_method` here it breaks subclasses that override
  #       `#symbolize_keys`, etc. - like {HashWithIndifferentAccess}
  # 
  def sym_keys! *args, &block;  symbolize_keys! *args, &block;  end
  def sym_keys  *args, &block;  symbolize_keys  *args, &block;  end
  
  def str_keys! *args, &block;  stringify_keys! *args, &block;  end
  def str_keys  *args, &block;  stringify_keys  *args, &block;  end
  
  
  # See {NRSER.bury!}
  def bury! key_path,
            value,
            parsed_key_type: :guess,
            clobber: false
    NRSER.bury! self,
                key_path,
                value,
                parsed_key_type: parsed_key_type,
                clobber: clobber
  end
  
  
  # Checks that `self` contains a single key/value pair (`#length` of 1)
  # and returns it as an array of length 2.
  # 
  # @return [Array]
  #   Array of length 2.
  # 
  # @raise [TypeError]
  #   If `self` has more than one key/value pair.
  # 
  def to_pair
    unless length == 1
      raise TypeError,
            "Hash has more than one pair: #{ self.inspect }"
    end
    
    first
  end
  
end
