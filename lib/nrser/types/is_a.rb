require 'nrser/refinements'
require 'nrser/types/type'
using NRSER

module NRSER::Types
  class IsA < NRSER::Types::Type
    attr_reader :klass
    
    def initialize klass, **options
      super **options
      @klass = klass
    end
    
    def name
      @name || "#{ self.class.short_name }(#{ @klass })"
    end
    
    def test value
      value.is_a? @klass
    end
  end # IsA
  
  # class membership
  def self.is_a klass
    IsA.new klass
  end
end # NRSER::Types