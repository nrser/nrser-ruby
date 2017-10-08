require 'nrser/refinements'
require 'nrser/types/type'

using NRSER
  
module NRSER::Types

  class HashType < IsA
    attr_reader :keys, :values #, :including, :exactly, :min, :max
    
    def initialize  keys: NRSER::Types::ANY,
                    values: NRSER::Types::ANY,
                    **options
      super ::Hash, **options
      
      @keys = NRSER::Types.make keys
      @values = NRSER::Types.make keys
      
    end
    
    def test value
      return false unless super(value)
      
      if keys == NRSER::Types::ANY && values == NRSER::Types::ANY
        return true
      end
      
      value.all? { |k, v|
        keys.test(k) && values.test(v)
      }
    end
  end # HashType
  
  HASH = HashType.new.freeze
  
  
  # Eigenclass (Singleton Class)
  # ========================================================================
  # 
  class << self
    
    # Type satisfied by {Hash} instances.
    # 
    # @param [Array] *args
    #   Passed to {NRSER::Types::HashType#initialize} unless empty.
    # 
    # @return [NRSER::Types::HASH]
    #   If `args` are empty.
    # 
    # @return [NRSER::Types::Type]
    #   Newly constructed hash type from `args`.
    # 
    def hash_ *args
      if args.empty?
        HASH
      else
        HashType.new *args
      end
    end
    
    alias_method :dict, :hash_
    
  end # class << self (Eigenclass)
  
end
