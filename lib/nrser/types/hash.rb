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
    
    
    # Type for a {Hash} that consists of only a single key and value pair.
    # 
    # @param [String] name:
    #   Name to give the new type.
    # 
    # @param [Hash] **options
    #   Other options to pass to 
    # 
    # @return [NRSER::Types::Type]
    # 
    def hash_pair **options
      if options.empty?
        HASH_PAIR
      else
        intersection is_a( Hash ), length( 1 ), **options
      end
    end # #pair
    
  end # class << self (Eigenclass)
  
  
  # Post-Processing
  # =======================================================================
  # 
  # Need to define the default constant types here 'cause they use the methods
  # defined above.
  # 
  # NOTE   All these should be **frozen**... I mean we still can't guarantee
  #       that users can't mutate them (which would break loose all sorts of
  #       hell), but it's better than nothing.
  # 
  
  HASH = HashType.new.freeze
  
  HASH_PAIR = hash_pair( name: 'HashPairType' ).freeze
  
end
