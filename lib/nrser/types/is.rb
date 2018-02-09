require 'nrser/refinements'
require 'nrser/types/type'
using NRSER

module NRSER::Types
  class Is < NRSER::Types::Type
    attr_reader :value
    
    def initialize value, **options
      super **options
      
      @value = value
    end
    
    def default_name
      "Is(#{ @value.inspect })"
    end
    
    def test value
      @value.equal? value
    end
    
    def == other
      equal?(other) || @value === other.value
    end
    
    # @return [String]
    #   a brief string description of the type - just it's {#name} surrounded
    #   by some back-ticks to make it easy to see where it starts and stops.
    # 
    def to_s
      "{ x ≡ #{ @value.inspect } }"
    end
    
    alias_method :inspect, :to_s
  end # Is
  
  # an exact value (using ===)
  def self.is value, **options
    Is.new value, **options
  end
  
end # NRSER::Types
