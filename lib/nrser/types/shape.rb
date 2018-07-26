# frozen_string_literal: true
# encoding: UTF-8


# Definitions
# =======================================================================

module NRSER::Types
  
  class Shape < Type
    
    
    # Attributes
    # ========================================================================
    
    # TODO document `pairs` attribute.
    # 
    # @return [Hash]
    #     
    attr_reader :pairs
    
    
    # Constructor
    # ======================================================================
    
    # Instantiate a new `NRSER::Types::Shape`.
    def initialize pairs, **options
      super **options
      @pairs = pairs.map { |k, v|
        [k, NRSER::Types.make( v )]
      }.to_h.freeze
    end # #initialize
    
    
    # Instance Methods
    # ======================================================================
    
    def test? value
      begin
        @pairs.all? { |k, v| v === value[k] }
      rescue
        false
      end
    end
    
    def explain
      inner = @pairs.map { |k, v|
        "[#{ k.inspect }]→#{ v.name }"
      }.join( ", " )
      
      if @pairs.count == 1
        inner
      else
        '(' + inner + ')'
      end
    end
    
    def has_from_data?
      pairs.values.all? { |type| type.has_from_data? }
    end
    
    
    def custom_from_data data
      pairs.map { |key, type|
        [ key, type.from_data( data[key] ) ]
      }.to_h
    end
    
  end # class Shape
  
  
  def_factory(
    :shape,
  ) do |pairs, **options|
    Shape.new pairs, **options
  end
  
end # module NRSER::Types
