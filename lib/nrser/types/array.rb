# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------
require 'nrser/types/type'
require 'nrser/types/is_a'


# Refinements
# =======================================================================

require 'nrser/refinements'
using NRSER


# Declarations
# =======================================================================

module NRSER; end


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
    
    attr_reader :item_type
    
    def initialize split_with: DEFAULT_SPLIT_WITH, **options
      super ::Array, **options
      @split_with = split_with
    end
    
    
    def default_name
      self.class.short_name
    end
    
    
    def item_type
      NRSER::Types.any
    end
    
    
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
    
    
    def from_s s
      # Use custom {@from_s} if we have one.
      return check( @from_s.call s ) unless @from_s.nil?
      
      # Does it looks like a JSON array?
      if NRSER.looks_like_json_array? s
        # It does! Load it
        begin
          array = JSON.load( s )
        rescue
          # pass - if we failed to load as JSON, it may just not be JSON, and
          # we can try the split approach below.
        else
          # Check value and return. If we fail the check here let the error
          # bubble up
          return check array
        end
      end
      
      # Split it with the splitter and check that
      check items_from_strings( s.split( @split_with ) )
    end
    
  end # ArrayType
  
  
  # Static instance that is satisfied by anything that is an {Array}.
  ARRAY = ArrayType.new.freeze
  
  
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
    
    def default_name
      "#{ super() }<#{ @item_type }>"
    end
    
    
    def test value
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
      @item_type.has_from_s?
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
  
  
  # Eigenclass (Singleton Class)
  # ========================================================================
  # 
  class << self
    
    # @!group Type Factory Functions
    
    # {NRSER::Types::ArrayType} / {NRSER::Types::ArrayOfType} factory function.
    # 
    # @param [Type | Object] item_type
    #   Optional type of items.
    # 
    # @return [NRSER::Types::Type]
    # 
    def array item_type = any, **options
      if item_type == any
        if options.empty?
          ARRAY
        else
          ArrayType.new **options
        end
      else
        ArrayOfType.new item_type, **options
      end
    end # #array
    
    alias_method :list, :array
    
  end # class << self (Eigenclass)
  
  
end # NRSER::Types
