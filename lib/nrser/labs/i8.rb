# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Deps
# -----------------------------------------------------------------------
require 'hamster'

# Project / Package
# -----------------------------------------------------------------------
require 'nrser/errors/type_error'


# Definitions
# =======================================================================

# Sick of typing "Hamster::Hash"...
# 
# Experimental Hamster builder shortcut things.
# 
module I8
  
  def self.[] value
    case value
    when ::Hash
      Hamster::Hash[value]
    when ::Array
      Hamster::Vector.new value
    when ::Set
      Hamster::Set.new value
    else
      raise NRSER::TypeError.new \
        "Value must be Hash or Array",
        found: value
    end
  end
  
end

def I8 value = nil
  value = value || yield
  
  case value
  when ::Hash
    Hamster::Hash[value]
  when ::Array
    Hamster::Vector.new value
  when ::Set
    Hamster::Set.new value
  else
    raise NRSER::TypeError.new \
      "Yielded value must be Hash or Array",
      found: value
  end
end
