# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

## Stdlib ##

require 'set'

## Deps ##

require 'hamster'

## Project / Package ##

require 'nrser/errors/type_error'

### Sub-Tree ###
require_relative "./i8/hash"
require_relative "./i8/set"
require_relative "./i8/sorted_set"
require_relative "./i8/to_mutable"
require_relative "./i8/vector"


# Refinements
# ============================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Definitions
# =======================================================================

# Sick of typing "Hamster::Hash"... and have some things to add, too!
# 
module I8
  
  # class List < Hamster::List; end # Not a class! Ugh...
  
  
  def self.[] value
    case value
    when  ::Hamster::Hash,
          ::Hamster::Vector,
          ::Hamster::Set,
          ::Hamster::SortedSet,
          ::Hamster::List
      value
    when ::Hash
      ::I8::Hash[value]
    when ::Array
      ::I8::Vector.new value
    when ::Set
      ::I8::Set.new value
    when ::SortedSet
      ::I8::SortedSet.new value
    else
      raise NRSER::TypeError.new \
        "Value must be Hash, Array, Set or SortedSet",
        found: value
    end
  end # .[]
  
end # module I8


# Method proxy to {I8.[]} allowing for different syntaxes.
# 
def I8 value = nil
  ::I8[ value || yield ]
end
