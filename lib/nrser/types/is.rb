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
    
    def name
      "Is(#{ @value.inspect })"
    end
    
    def test value
      @value === value
    end
  end # Is
  
  # an exact value (using ===)
  def self.is value, **options
    Is.new value, **options
  end
  
end # NRSER::Types