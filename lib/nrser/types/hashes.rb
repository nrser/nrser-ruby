# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require_relative './type'


# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# ========================================================================

# A type who's members simply are {Hash} instances.
# 
# Implements {#from_s} to provide JSON/YAML detection, as well as "simple"
# loading aimed at CLI option values.
# 
# @note
#   Construct {HashType} types using the {.Hash} factory.
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
  def keys; NRSER::Types.Top; end
  
  
  # In order to provide the same interface as {HashOfType}, this method
  # always returns {NRSER::Types.any}.
  # 
  # @return [NRSER::Types::Type]
  # 
  def values; NRSER::Types.Top; end
  
  
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
# @note
#   Construct {HashOfType} types using the {.Hash} factory.
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
    !@from_s.nil? || [keys, values].all?( &:has_from_s )
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
    "Hash<#{ keys.explain }, #{ values.explain }>"
  end
  
end # HashType


# @!group Hash Type Factories
# ----------------------------------------------------------------------------

# @!method self.Hash keys: self.Top, values: self.Top, **options
#   Type satisfied by {Hash} instances with optional key and value types.
#   
#   @param [TYPE] keys
#     Type for the hash keys. Will be made into a type by {.make} if it's not 
#     one already.
#     
#     **WARNING**   Don't pass `nil` unless you mean that all the keys must be
#                   `nil`! Omit the keyword or pass {.Top}.
#   
#   @param [TYPE] values
#     Type for the hash values. Will be made into a type by {.make} if it's not 
#     one already.
#     
#     **WARNING**   Don't pass `nil` unless you mean that all the values must be
#                   `nil`! Omit the keyword or pass {.Top}.
# 
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [HashType]
#   
def_type        :Hash,
  aliases:      [ :dict, :hash_type ],
  parameterize: [ :keys, :values ],
&->( keys: self.Top, values: self.Top, **options ) do
  if keys != self.Top || values != self.Top
    HashOfType.new keys: keys, values: values, **options
  else
    HashType.new **options
  end
end # .Hash

# @!endgroup Hash Type Factories # *******************************************


# /Namespace
# ========================================================================

end # module Types
end # module NRSER
