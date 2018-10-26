# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require 'nrser/core_ext/hash/keys'

require_relative './type'
require_relative './combinators'
require_relative './is'
require_relative './bounded'


# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# ========================================================================

# Specify types for value attributes.
# 
# @note
#   Construct {Attributes} types using the {.Attributes} factory.
# 
class Attributes < Type

  # Attributes
  # ========================================================================

  # Attribute types by name.
  # 
  # @return [Hash<Symbol, Type>]
  #     
  attr_reader :types

  
  # Construct an `AttrsType`.
  # 
  # @param [Hash<#to_sym, TYPE>] attrs
  #   Map of attribute names to their types (`TYPE` values will be passed
  #   through {NRSER::Types.make} to get a type instance).
  #   
  #   May not be empty.
  # 
  def initialize attrs, **options
    super **options
    
    if attrs.empty?
      raise ArgumentError,
        "Must provide at least one attribute name/type pair"
    end
    
    @types = attrs.map { |k, v|
      [ k.to_sym, NRSER::Types.make( v ) ]
    }.to_h.freeze
  end


  # @!group Display Instance Methods
  # --------------------------------------------------------------------------

  def type_strings method:
    types.map { |name, type|
      "##{ name }#{ RESPONDS_WITH }#{ type.public_send method }"
    }
  end


  def default_name
    type_strings = self.type_strings method: :name

    if type_strings.length == 1
      type_strings[0]
    else
      L_PAREN + type_strings.join( " #{ AND } " ) + R_PAREN
    end
  end


  def default_symbolic
    type_strings = self.type_strings method: :symbolic

    if type_strings.length == 1
      type_strings[0]
    else
      L_PAREN + type_strings.join( " #{ AND } " ) + R_PAREN
    end
  end
  
  
  # @see NRSER::Types::Type#explain
  # 
  # @return [String]
  # 
  def explain
    "#{ self.class.demod_name }<" +
    type_strings( method: :explain ).join( ', ' ) +
    ">"
  end
  
  
  # @see NRSER::Types::Type#test
  # 
  # @return [Boolean]
  # 
  def test? value
    types.all? { |name, type|
      value.respond_to?( name ) &&
        type.test?( value.method( name ).call )
    }
  end
  
end # Attributes


# @!group Attributes Type Factories
# ----------------------------------------------------------------------------

# @!method self.Attributes attrs, **options
#   Get a {Type} that checks the types of one or more attributes on values.
#   
#   @example Type where first element of an Enumerable is a String
#     string_first = intersection Enumerable, attrs(first: String)
#   
#   @param [Hash<#to_sym, (Type | Object)>] attrs
#     
# 
def_type          :Attributes,
  parameterize:   :attributes,
  aliases:      [ :attrs, ],
&->( attributes, **options ) do
  Attributes.new attributes, **options
end


# @!method self.Length **options
#   
#   @overload length exact, options = {}
#     Get a length attribute type that specifies an `exact` value.
#     
#     @example
#       only_type = NRSER::Types.length 1
#       
#       only_type.test []
#       # => false
#       
#       only_type.test [:x]
#       # => true
#       
#       only_type.test [:x, :y]
#       # => false
#     
#     @param [Integer] exact
#       Exact non-negative integer that the length must be to satisfy the
#       type created.
#     
#     @param [Hash] options
#       Options hash passed up to {NRSER::Types::Type} constructor.
#     
#     @return [NRSER::Types::Attributes]
#       Type satisfied by a `#length` attribute that is exactly `exact`.
#   
#   
#   @overload length bounds, options = {}
#     Get a length attribute type satisfied by values within a `:min` and
#     `:max` (inclusive).
#     
#     @example
#       three_to_five = NRSER::Types.length( {min: 3, max: 5}, name: '3-5' )
#       three_to_five.test [1, 2]               # => false
#       three_to_five.test [1, 2, 3]            # => true
#       three_to_five.test [1, 2, 3, 4]         # => true
#       three_to_five.test [1, 2, 3, 4, 5]      # => true
#       three_to_five.test [1, 2, 3, 4, 5, 6]   # => false
#   
#     @param [Hash] bounds
#     
#     @option bounds [Integer] :min
#       An optional minimum value that the `#length` should not be less than.
#     
#     @option bounds [Integer] :max
#       An optional maximum value that the `#length` should not be more than.
#     
#     @option bounds [Integer] :length
#       An optional value for both the minimum and maximum.
#     
#     @param [Hash] options
#       Options hash passed up to {NRSER::Types::Type} constructor.
#     
#     @return [NRSER::Types::Attributes]
#       Type satisfied by a `#length` attribute between the `:min` and `:max`
#       (inclusive).
# 
def_type        :Length,
  # TODO  This would need special attention if we ever started using the
  #       `parameterize` data for anything...
  parameterize: :args,
&->( *args ) do
  bounds = {}
  options = if args[1].is_a?( Hash ) then args[1] else {} end
  
  case args[0]
  when ::Integer
    # It's just a length
    return attrs(
      { length: is( non_neg_int.check!( args[0] ) ) },
      **options
    )
    
    bounds[:min] = bounds[:max] = non_neg_int.check args[0]
    
  when ::Hash
    # It's keyword args
    kwds = args[0].sym_keys
    
    # Pull any :min and :max in the keywords
    bounds[:min] = kwds.delete :min
    bounds[:max] = kwds.delete :max
    
    # But override with :length if we got it
    if length = kwds.delete(:length)
      bounds[:min] = length
      bounds[:max] = length
    end
    
    # (Reverse) merge anything else into the options (options hash values
    # take precedence)
    options = kwds.merge options
    
  else
    raise ArgumentError, <<-END.squish
      arg must be positive integer or option hash, found:
      #{ args[0].inspect } of type #{ args[0].class }
    END
    
  end
  
  bounded_type = self.Bounded bounds
  
  length_type = if !bounded_type.min.nil? && bounded_type.min >= 0
    # We don't need the non-neg check
    bounded_type
  else
    # We do need the non-neg check
    intersection(non_neg_int, bounded_type)
  end
  
  options[:name] ||= "Length<#{ bounded_type.name }>"
  
  self.Attributes({ length: length_type }, options)
end # .Length

# @!endgroup Attributes Type Factories # *************************************


# /Namespace
# ========================================================================

end # module Types
end # module NRSER
