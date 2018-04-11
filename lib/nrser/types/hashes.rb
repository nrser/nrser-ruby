require_relative './type'
  
module NRSER::Types
  
  # A type who's members simply are {Hash} instances.
  # 
  # Implements {#from_s} to provide JSON/YAML detection, as well as "simple"
  # loading aimed at CLI option values.
  # 
  class HashType < IsA
  
    # Constructor
    # ========================================================================
    
    # Instantiate a new `HashType`.
    def initialize **options
      super ::Hash, **options
    end # #initialize
    
    
    # Instance Methods
    # ========================================================================
    
    # In order to provide the same interface as {HashOfType}, this method
    # always returns {NRSER::Types.any}.
    # 
    # @return [NRSER::Types::Type]
    # 
    def keys; NRSER::Types.any; end
    
    
    # In order to provide the same interface as {HashOfType}, this method
    # always returns {NRSER::Types.any}.
    # 
    # @return [NRSER::Types::Type]
    # 
    def values; NRSER::Types.any; end
    
    
    protected
    # ========================================================================

      # Hook to provide custom loading from strings, which will be called by
      # {NRSER::Types::Type#from_s}, unless a `@from_s`
      # 
      def custom_from_s string
        # Does it looks like a JSON / inline-YAML object?
        if NRSER.looks_like_json_object? string
          # It does! Load it
          begin
            return YAML.load string
          rescue
            # pass - if we failed to load as JSON, it may just not be JSON, and
            # we can try the split approach below.
          end
        end
        
        # Try parsing as a "simple string", aimed at CLI option values.
        from_simple_s string
      end
      
      
      def from_simple_s string
        hash = {}
        
        pair_strs = string.split NRSER::Types::ArrayType::DEFAULT_SPLIT_WITH
        
        pair_strs.each do |pair_str|
          key_str, match, value_str = pair_str.rpartition /\:\s*/m
          
          if match.empty?
            raise NRSER::Types::FromStringError.new(
              "Could not split pair string", pair_str,
              type: self,
              string: string,
              pair_str: pair_str,
            ) do
              <<~END
                Trying to parse a {Hash} out of a string using the "simple"
                approach, which splits
                
                1.  First by `,` (followed by any amount of whitespace)
                2.  Then by the last `:` in each of those splits (also followed)
                    by any amount of whitespace)
              END
            end
          end
          
          key = if keys == NRSER::Types.any
            key_str
          else
            keys.from_s key_str
          end
          
          value = if values == NRSER::Types.any
            value_str
          else
            values.from_s value_str
          end
          
          hash[key] = value
        end
        
        hash
      end # #from_simple_s
      
    public # end protected *****************************************************
    
  end # class HashType
  
  
  # A {Hash} type with typed keys and/or values.
  # 
  class HashOfType < HashType
    
    # Attributes
    # ========================================================================
    
    # The type of the hash keys.
    # 
    # @return [NRSER::Types::Type]
    #     
    attr_reader :keys
    
    
    # The type of the hash values.
    # 
    # @return [NRSER::Types::Type]
    # 
    attr_reader :values
    
    
    # Constructor
    # ========================================================================
    
    def initialize  keys: NRSER::Types.any,
                    values: NRSER::Types.any,
                    **options
      super **options
      
      @keys = NRSER::Types.make keys
      @values = NRSER::Types.make values
    end
    
    
    # Instance Methods
    # ========================================================================
    
    # Overridden to check that both the {#keys} and {#values} types can
    # load from a string.
    # 
    # @see NRSER::Types::Type#has_from_s?
    # 
    def has_from_s?
      super() && [keys, values].all?( &:has_from_s )
    end
    
    
    # @see NRSER::Types::Type#test
    # 
    # @return [Boolean]
    # 
    def test? value
      return false unless super( value )
      
      value.all? { |k, v|
        keys.test( k ) && values.test( v )
      }
    end
    
    
    # @see NRSER::Types::Type#explain
    # 
    # @return [String]
    # 
    def explain
      "Hash<#{ @keys.name }, #{ @values.name }>"
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
  def_factory :hash_type, aliases: [:dict, :hash_] do |**kwds|
    if kwds.key?( :keys ) || kwds.key?( :values )
      HashOfType.new **kwds
    else
      HashType.new **kwds
    end
  end
  
end
