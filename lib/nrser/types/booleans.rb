# encoding: UTF-8
# frozen_string_literal: true

# Need truthy and falsy parse values
require 'nrser/functions/object/truthy'

require_relative './type'
require_relative './is'
require_relative './combinators'

  
module NRSER::Types
  
  # @todo document TrueType class.
  class TrueType < Is
    
    # Instantiate a new `TrueType`.
    # 
    def initialize **options
      super true, **options
    end # #initialize
    
    
    protected
    # ========================================================================
      
      def custom_from_s string
        return true if NRSER::TRUTHY_STRINGS.include?( string.downcase )
        
        raise NRSER::Types::FromStringError.new \
          type: self,
          string: string,
          binding: binding,
          details: -> {
            <<~END
              Down-cased `string` must be one of:
              
                  <%= NRSER::TRUTHY_STRINGS.to_a %>
            END
          }
      end
      
    public # end protected *****************************************************
    
  end # class TrueType
  
  
  def_factory :true do |**options|
    TrueType.new **options
  end
  
  TRUE = self.true
  
  FALSE = is false, name: 'false', from_s: ->(string) {
    if ['false', 'f', '0', 'no', 'n', 'off'].include? string.downcase
      false
    else
      raise TypeError, "can not convert to true: #{ string.inspect }"
    end
  }
  
  def self.false
    FALSE
  end
  
  BOOL = union TRUE, FALSE
  
  # true or false
  def self.bool
    BOOL
  end
  
  def self.boolean
    bool
  end
  
end # NRSER::Types
