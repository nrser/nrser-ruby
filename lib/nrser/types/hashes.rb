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
      @values = NRSER::Types.make values
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
    
    def default_name
      "Hash{#{ @keys.name }=>#{ @values.name }}"
    end
  end # HashType
  
  

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
  def_factory :hash_type, aliases: [:dict, :hash_] do |*args|
    if args.empty?
      HASH
    else
      HashType.new *args
    end
  end
  
  HASH = HashType.new.freeze
  
end
