require 'nrser/refinements'
require 'nrser/types/type'
require 'nrser/types/is_a'

using NRSER
  
module NRSER::Types
  class Array < IsA
    SEP = /\,\s+/
    
    attr_reader :item_type
    
    def initialize item_type = NRSER::Types.any, **options
      super ::Array, **options
      @item_type = NRSER::Types.make item_type
    end
    
    def test value
      super(value) && if @item_type == NRSER::Types.any
        true
      else
        value.all? {|v| @item_type.test v}
      end
    end
    
    def default_name
      "#{ self.class.short_name }<#{ @item_type }>"
    end
    
    def has_from_s?
      @item_class.has_from_s?
    end
    
    def from_s s
      # does it looks like json?
      if s.start_with? '['
        begin
          return JSON.load s
        rescue
        end
      end
      
      s.split SEP
    end
    
    def == other
      equal?(other) || (
        other.class == self.class && @item_type == other.item_type
      )
    end
  end # Array
  
  # array
  def self.array *args
    Array.new *args
  end
  
  def self.list *args
    array *args
  end
end # NRSER::Types
