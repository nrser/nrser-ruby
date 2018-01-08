require 'nrser/refinements'
require 'nrser/types/type'
require 'nrser/types/is'
require 'nrser/types/combinators'

using NRSER
  
module NRSER::Types
  # booleans
  # ========
  
  TRUE = is true, name: 'true', from_s: ->(string) {
    if ['true', 't', '1', 'yes', 'y', 'on'].include? string.downcase
      true
    else
      raise TypeError, "can not convert to true: #{ string.inspect }"
    end
  }
  
  def self.true
    TRUE
  end
  
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
