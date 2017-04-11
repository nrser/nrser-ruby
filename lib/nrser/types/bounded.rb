require 'nrser/refinements'
require 'nrser/types/type'

using NRSER
  
module NRSER::Types  
  class Bounded < NRSER::Types::Type
    def initialize **options
      @min = options[:min]
      @max = options[:max]
    end
    
    def test value
      return false if @min && value < @min
      return false if @max && value > @max
      true
    end
    
    def default_name
      attrs_str = ['min', 'max'].map {|name|
        [name, instance_variable_get("@#{ name }")]
      }.reject {|name, value|
        value.nil?
      }.map {|name, value|
        "#{ name }=#{ value }"
      }.join(', ')
      
      "#{ self.class.short_name }(#{ attrs_str })"
    end
  end # Bounded
  
  def self.bounded **options
    Bounded.new **options
  end
   
end # NRSER::Types