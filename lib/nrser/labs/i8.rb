# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------
require 'set'

# Deps
# -----------------------------------------------------------------------
require 'hamster'

# Project / Package
# -----------------------------------------------------------------------
require 'nrser/errors/type_error'

require 'nrser/refinements/types'
using NRSER::Types


# Definitions
# =======================================================================

# Sick of typing "Hamster::Hash"...
# 
# Experimental Hamster sugary sweet builder shortcut things.
# 
module I8
  
  # Easy way to get the class names shorter..?
  class Vector < Hamster::Vector; end


  class Hash < Hamster::Hash; end

  
  class Set < Hamster::Set

    # Get a {I8::Set} containing `items`.
    #
    # Overridden to...
    #
    # 1.  Return `items` if items is already a {I8::Set}... sort of like a copy
    #     constructor that doesn't actually copy because the instances are
    #     immutable.
    #
    # 2.  Return an instance of `self` pointing to `items`'s {Hamster::Trie}
    #     if `items` is a {Hamster::Set}; this way you get an instance of
    #     the correct class but don't do any additional instantiation.
    # 
    # 3.  Returns {.empty} if `items` responds to `#empty?` truthfully.
    # 
    # Otherwise, defers to `super`.
    # 
    # @param [#each] items
    #   Items for the new set to contain.
    # 
    # @return [I8::Set]
    #
    def self.new items = []
      case items
      when self
        items
      when Hamster::Set
        alloc items.instance_variable_get( :@trie )
      else
        if items.respond_to?( :empty? ) && items.empty?
          self.empty
        else
          super items
        end
      end
    end

    # Override to build our empty set through {.alloc} so that we can return
    # it in {.new}.
    # 
    # @return [I8::Set]
    # 
    def self.empty
      @empty ||= alloc Hamster::Trie.new( 0 )
    end

  end # class Set


  class SortedSet < Hamster::SortedSet; end
  # class List < Hamster::List; end # Not a class! Ugh...
  
  
  def self.[] value
    case value
    when  Hamster::Hash,
          Hamster::Vector,
          Hamster::Set,
          Hamster::SortedSet,
          Hamster::List
      value
    when ::Hash
      I8::Hash[value]
    when ::Array
      I8::Vector.new value
    when ::Set
      I8::Set.new value
    when ::SortedSet
      I8::SortedSet.new value
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
  I8[ value || yield ]
end
