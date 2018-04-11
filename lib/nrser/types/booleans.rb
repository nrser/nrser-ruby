# encoding: UTF-8
# frozen_string_literal: true

# Need truthy and falsy parse values
require 'nrser/functions/object/truthy'

require_relative './type'
require_relative './is'
require_relative './combinators'

  
module NRSER::Types
  
  # Abstract base class for {TrueType} and {FalseType}.
  # 
  class BooleanType < Is
    
    # Instantiate a new `BooleanType`.
    # 
    def initialize value, **options
      # Check it's a boolean
      unless true.equal?( value ) || false.equal?( value )
        raise ArgumentError.new \
          "`value` arg must be `true` or `false`, found #{ value.inspect }"
      end
      
      super value, **options
    end # #initialize
    
    
    protected
    # ========================================================================
      
      def custom_from_s string
        return value if self::STRINGS.include?( string.downcase )
        
        raise NRSER::Types::FromStringError.new \
          type: self,
          string: string,
          binding: binding,
          details: -> {
            <<~END
              Down-cased `string` must be one of:
              
                  <%= self::STRINGS.to_a %>
            END
          }
      end
      
    public # end protected *****************************************************
    
  end # class TrueType
  
  
  # A type for only the `true`.
  # 
  # Provides a {#custom_from_s} to load from CLI options and ENV var-like
  # string values.
  # 
  class TrueType < BooleanType
    
    STRINGS = NRSER::TRUTHY_STRINGS
    
    # Instantiate a new `TrueType`.
    # 
    def initialize **options
      super true, **options
    end # #initialize
    
  end # class TrueType
  
  
  # A type for only `false`.
  # 
  # Provides a {#custom_from_s} to load from CLI options and ENV var-like
  # string values.
  # 
  class FalseType < BooleanType
    
    STRINGS = NRSER::FALSY_STRINGS
    
    # Instantiate a new `TrueType`.
    # 
    def initialize **options
      super false, **options
    end # #initialize
    
  end # class FalseType
  
  
  def_factory :true do |**options|
    TrueType.new **options
  end
  
  
  def_factory :false do |**options|
    FalseType.new **options
  end
  
  
  def_factory(
    :bool,
    aliases: [:boolean],
  ) do |**options|
    union self.true, self.false, **options
  end
  
end # NRSER::Types
