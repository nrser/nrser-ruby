require 'nrser/refinements'
require 'nrser/types/type'

using NRSER

# base class for Union and Intersection which combine over a set of types.
module NRSER::Types
  class Combinator < NRSER::Types::Type
    attr_reader :types
    
    def initialize *types, **options
      super **options
      @types = types.map {|type| NRSER::Types.make type}
    end
    
    def name
      @name || (
        "#{ self.class.short_name }(" + 
        @types.map {|type| type.name }.join(',') + 
        ")"
      )
    end
    
    # a combinator may attempt to parse from a string if any of it's types
    # can do so
    def has_from_s?
      @types.any? {|type| type.has_from_s?}
    end
    
    # a combinator iterates through each of it's types, trying the
    # conversion and seeing if the result satisfies the combinator type
    # itself. the first such value found is returned.
    def from_s s
      @types.each {|type|
        if type.respond_to? :from_s
          begin
            return check type.from_s(s)
          rescue TypeError => e
            # pass
          end
        end
      }
      
      raise TypeError,
        "none of union types could convert #{ string.inspect }"
    end
    
    def == other
      equal?(other) || (
        other.class == self.class && other.types == @types
      )
    end
  end
  
  class Union < Combinator        
    def test value
      @types.any? {|type| type.test value}
    end
  end # Union
  
  # match any of the types
  def self.union *types, **options
    NRSER::Types::Union.new *types, **options
  end
  
  singleton_class.send :alias_method, :one_of, :union
  
  class Intersection < Combinator      
    def test value
      @types.all? {|type| type.test value}
    end
  end
  
  # match all of the types
  def self.intersection *types, **options
    Intersection.new *types, **options
  end
  
  singleton_class.send :alias_method, :all_of, :intersection
  
end # NRSER::Types