# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require 'nrser/types/type'


# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# ========================================================================

class Bounded < NRSER::Types::Type
  
  # Minimum value.
  # 
  # @return [Number]
  #     
  attr_reader :min
  
  
  # Minimum value.
  # 
  # @return [Number]
  # 
  attr_reader :max
  
  
  def initialize  min: nil,
                  max: nil,
                  **options
    super **options
    
    @min = min
    @max = max
  end
  
  def test? value
    return false if @min && value < @min
    return false if @max && value > @max
    true
  end

  def symbolic
    if min
      if max
        # has min and max
        "{ x : #{ min } #{ NRSER::Types::LEQ } x #{ NRSER::Types::LEQ } #{ max } }"
      else
        # only has min
        "{ x : x #{ NRSER::Types::GEQ } #{ min } }"
      end
    else
      # only has max
      "{ x : x #{ NRSER::Types::LEQ } #{ max } }"
    end
  end
  
  def explain
    attrs_str = ['min', 'max'].map {|name|
      [name, instance_variable_get("@#{ name }")]
    }.reject {|name, value|
      value.nil?
    }.map {|name, value|
      "#{ name }=#{ value }"
    }.join(', ')
    
    "#{ self.class.demod_name }<#{ attrs_str }>"
  end
  
end # Bounded


# @!group Bounded Type Factories
# ----------------------------------------------------------------------------

#@!method Bounded **options
#   @todo Document Bounded type factory.
#   
#   @param [Hash] **options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :Bounded,
  parameterize: [ :min, :max ],
&->( min: nil, max: nil, **options ) do
  Bounded.new min: min, max: max, **options
end # .Bounded

# @!endgroup Bounded Type Factories # ****************************************


# /Namespace
# ========================================================================

end # module Types
end # module NRSER
