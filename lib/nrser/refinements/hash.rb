# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------
require_relative './enumerable'
require_relative './tree'


# Definitions
# =======================================================================

module NRSER
  
  refine ::Hash do
    include NRSER::Refinements::Enumerable
    include NRSER::Refinements::Tree
    
    # See {NRSER.except_keys!}.
    def except! *keys
      NRSER.except_keys! self, *keys
    end
    
    alias_method :omit!, :except!
    
    
    # See {NRSER.except_keys}.
    def except *keys
      NRSER.except_keys self, *keys
    end
    
    alias_method :omit, :except
    
    
    # See {NRSER.slice_keys}.
    def slice *keys
      NRSER.slice_keys self, *keys
    end
    
    
    # See {NRSER.transform_keys!}
    def transform_keys! &block
      return enum_for(:transform_keys!) { size } unless block_given?
      NRSER.transform_keys! self, &block
    end
    
    
    # See {NRSER.transform_keys}
    def transform_keys &block
      return hash.enum_for(:transform_keys) { size } unless block_given?
      NRSER.transform_keys self, &block
    end
    
    
    # See {NRSER.symbolize_keys!}
    def symbolize_keys!
      NRSER.symbolize_keys! self
    end
    
    
    # See {NRSER.symbolize_keys}
    def symbolize_keys
      NRSER.symbolize_keys self
    end
    
    
    # See {NRSER.stringify_keys!}
    def stringify_keys!
      NRSER.stringify_keys! self
    end
    
    
    # See {NRSER.stringify_keys}
    def stringify_keys
      NRSER.stringify_keys self
    end
    
    
    # See {NRSER.map_hash_keys}
    def map_keys &block
      NRSER.map_keys self, &block
    end
    
    
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
    
    
    # See {NRSER.deep_merge}
    def deep_merge other_hash, &block
      NRSER.deep_merge self, other_hash, &block
    end
    
    
    # See {NRSER.deep_merge!}
    def deep_merge! other_hash, &block
      NRSER.deep_merge! self, other_hash, &block
    end
    
  end # refine ::Hash
end # NRSER