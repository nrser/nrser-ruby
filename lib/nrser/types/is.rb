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
  end # Is
  
  # an exact value (using ===)
  def self.is value, **options
    Is.new value, **options
  end
  
end # NRSER::Types