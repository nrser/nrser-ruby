# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require 'nrser/core_ext/hash'

require_relative './type'
require_relative './combinators'
require_relative './is'


# Definitions
# ========================================================================
  
module NRSER::Types
  
  # Specify types for value attributes.
  # 
  class AttrsType < NRSER::Types::Type
    
    # Construct an `AttrsType`.
    # 
    # @param [Hash<Symbol, TYPE>] attrs
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
      
      @attrs = attrs.transform_values &NRSER::Types.maker
    end
    
    
    # @see NRSER::Types::Type#explain
    # 
    # @return [String]
    # 
    def explain
      attrs_str = @attrs.map { |name, type|
        "##{ name }#{ RESPONDS_WITH }#{ type.name }"
      }.join(', ')
      
      if @attrs.length < 2
        attrs_str
      else
        L_PAREN + attrs_str + R_PAREN
      end
    end
    
    
    # @see NRSER::Types::Type#test
    # 
    # @return [Boolean]
    # 
    def test? value
      @attrs.all? { |name, type|
        value.respond_to?( name ) &&
          type.test?( value.method( name ).call )
      }
    end
    
  end # AttrsType
  
  
  # @!group Type Factory Functions
  
  # Get a {Type} that checks the types of one or more attributes on values.
  # 
  # @example Type where first element of an Enumerable is a String
  #   string_first = intersection Enumerable, attrs(first: String)
  # 
  def_factory :attrs do |*args|
    case args.length
    when 0
      raise NRSER::ArgumentError.new \
        "requires at least one argument"
    when 1
      attrs = args[0]
      options = {}
    when 2
      attrs = args[0]
      options = args[1]
    end
    
    AttrsType.new attrs, **options
  end
  
  
  # @overload length exact, options = {}
  #   Get a length attribute type that specifies an `exact` value.
  #   
  #   @example
  #     only_type = NRSER::Types.length 1
  #     
  #     only_type.test []
  #     # => false
  #     
  #     only_type.test [:x]
  #     # => true
  #     
  #     only_type.test [:x, :y]
  #     # => false
  #   
  #   @param [Integer] exact
  #     Exact non-negative integer that the length must be to satisfy the
  #     type created.
  #   
  #   @param [Hash] options
  #     Options hash passed up to {NRSER::Types::Type} constructor.
  #   
  #   @return [NRSER::Types::Attrs]
  #     Type satisfied by a `#length` attribute that is exactly `exact`.
  # 
  # 
  # @overload length bounds, options = {}
  #   Get a length attribute type satisfied by values within a `:min` and
  #   `:max` (inclusive).
  #   
  #   @example
  #     three_to_five = NRSER::Types.length( {min: 3, max: 5}, name: '3-5' )
  #     three_to_five.test [1, 2]               # => false
  #     three_to_five.test [1, 2, 3]            # => true
  #     three_to_five.test [1, 2, 3, 4]         # => true
  #     three_to_five.test [1, 2, 3, 4, 5]      # => true
  #     three_to_five.test [1, 2, 3, 4, 5, 6]   # => false
  # 
  #   @param [Hash] bounds
  #   
  #   @option bounds [Integer] :min
  #     An optional minimum value that the `#length` should not be less than.
  #   
  #   @option bounds [Integer] :max
  #     An optional maximum value that the `#length` should not be more than.
  #   
  #   @option bounds [Integer] :length
  #     An optional value for both the minimum and maximum.
  #   
  #   @param [Hash] options
  #     Options hash passed up to {NRSER::Types::Type} constructor.
  #   
  #   @return [NRSER::Types::Attrs]
  #     Type satisfied by a `#length` attribute between the `:min` and `:max`
  #     (inclusive).
  # 
  def self.length *args
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
    
    bounded_type = bounded bounds
    
    length_type = if !bounded_type.min.nil? && bounded_type.min >= 0
      # We don't need the non-neg check
      bounded_type
    else
      # We do need the non-neg check
      intersection(non_neg_int, bounded_type)
    end
    
    options[:name] ||= "Length<#{ bounded_type.name }>"
    
    attrs({ length: length_type }, options)
  end # #length
  
end # NRSER::Types
