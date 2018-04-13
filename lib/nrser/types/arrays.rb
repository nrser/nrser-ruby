# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require_relative './is_a'


# Definitions
# =======================================================================
  
module NRSER::Types
  
  class ArrayType < IsA
    # Default value to split strings with in {#from_s} if the string provided
    # does is not recognized as an encoding format (as of writing, JSON is
    # the only format we attempt to detect).
    # 
    # Splits
    DEFAULT_SPLIT_WITH = /\,\s*/m
    
    def initialize split_with: DEFAULT_SPLIT_WITH, **options
      super ::Array, **options
      @split_with = split_with
    end
    
    
    def item_type; NRSER::Types.any; end
    
    
    # Called on an array of string items that have been split
    # from a single string by {#from_s} to convert each individual item before
    # {#check} is called on the value.
    # 
    # {NRSER::Types::ArrayType} implementation is a no-op that just returns
    # `items` - this method is in place for subclasses to override.
    # 
    # @param [Array<String>] items
    # 
    # @return [Array]
    # 
    def items_from_strings items
      items
    end
    
    
    def custom_from_s string
      # Does it looks like a JSON array?
      if NRSER.looks_like_json_array? string
        # It does! Load it
        begin
          return JSON.load( string )
        rescue
          # pass - if we failed to load as JSON, it may just not be JSON, and
          # we can try the split approach below.
        end
      end
      
      # Split it with the splitter and check that
      items_from_strings( string.split( @split_with ) )
    end
    
  end # ArrayType
  
  
  # Type for arrays where every entry satisfies a specific type.
  # 
  # Broken out from {ArrayType} so that {TupleType} can inherit from
  # {ArrayType} and get share it's string handling functionality without
  # receiving the entry type stuff (which it handles differently).
  # 
  class ArrayOfType < ArrayType
    
    # Attributes
    # ======================================================================
    
    # Type that all items must satisfy for an array to be a member of this
    # type.
    # 
    # @return [NRSER::Types::Type]
    #     
    attr_reader :item_type
    
    
    # Constructor
    # ======================================================================
    
    # Instantiate a new `ArrayOfType`.
    def initialize item_type, **options
      super **options
      @item_type = NRSER::Types.make item_type
    end # #initialize
    
    
    # Instance Methods
    # ======================================================================
    
    def explain
      "#{ super() }<#{ item_type.explain }>"
    end
    
    
    def test? value
      # Check the super method first, which will test if `value` is an Array
      # instance, and return `false` if it's not.
      return false unless super( value )
      
      # Otherwise test all the items
      value.all? &@item_type.method( :test )
    end
    
    
    # {ArrayOfType} can convert values from strings if it's {#item_type}
    # can convert values from strings.
    # 
    # @return [Boolean]
    # 
    def has_from_s?
      @from_s || @item_type.has_from_s?
    end
    
    
    def items_from_strings items
      items.map &@item_type.method( :from_s )
    end
    
    
    # @todo
    #   I'm not even sure why this is implemented... was it used somewhere?
    #   
    #   It doesn't seems too well thought out... seems like the reality of
    #   comparing types is much more complicated?
    # 
    def == other
      equal?(other) || (
        other.class == self.class && @item_type == other.item_type
      )
    end
    
  end # class ArrayOfType
  
  
  # {NRSER::Types::ArrayType} / {NRSER::Types::ArrayOfType} factory function.
  # 
  # @param [Type | Object] item_type
  #   Optional type of items.
  # 
  # @return [NRSER::Types::Type]
  # 
  def_factory(
    :array,
    aliases: [:list],
  ) do |item_type = any, **options|
    if item_type == any
      ArrayType.new **options
    else
      ArrayOfType.new item_type, **options
    end
  end # #array
  
end # NRSER::Types
