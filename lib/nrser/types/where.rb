require 'nrser/refinements'
using NRSER

module NRSER::Types
  class Where < NRSER::Types::Type
    attr_reader :predicate
    
    def initialize predicate, **options
      super **options
      @predicate = predicate
    end
    
    def test value
      !!@predicate.call(value)
    end
  end # Where
  
  # create a type based on a predicate
  def self.where **options, &block
    Where.new block, **options
  end
end # NRSER::Types