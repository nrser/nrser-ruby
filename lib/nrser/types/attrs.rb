require 'nrser/refinements'
require 'nrser/types/type'
require 'nrser/types/combinators'

using NRSER
  
module NRSER::Types
  class Attrs < NRSER::Types::Type
    def initialize attrs, **options
      super **options
      
      if attrs.empty?
        raise ArgumentError,
          "Must provide at least one attribute name/type pair"
      end
      
      @attrs = NRSER.map_values(attrs) { |name, type|
        NRSER::Types.make type
      }
    end
    
    def default_name
      attrs_str = @attrs.map { |name, type|
        "##{ name }#{ RESPONDS_WITH }#{ type.name }"
      }.join(', ')
      
      if @attrs.length < 2
        attrs_str
      else
        L_PAREN + attrs_str + R_PAREN
      end
    end
    
    def test value
      @attrs.all? { |name, type|
        value.respond_to?(name) && type.test(value.method(name).call)
      }
    end
  end # Attrs
  
  
  # @!group Type Factory Functions
  
  # Get a {Type} that checks the types of one or more attributes on values.
  # 
  # @example Type where first element of an Enumerable is a String
  #   string_first = intersection Enumerable, attrs(first: String)
  # 
  factory :attrs do |attrs, **options|
    Attrs.new attrs, **options
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
      bounds[:min] = bounds[:max] = non_neg_int.check args[0]
      
    when ::Hash
      # It's keyword args
      kwds = NRSER.symbolize_keys args[0]
      
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
