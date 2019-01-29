# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Stdlib ###

require "set"

### Deps ###

require "hamster"

### Project / Package ###

require_relative "./to_mutable"


# Namespace
# =======================================================================

module  I8


# Definitions
# =======================================================================

class Set < ::Hamster::Set
  
  # Singleton Methods
  # ==========================================================================

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
    when ::Hamster::Set
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
    @empty ||= alloc ::Hamster::Trie.new( 0 )
  end
  

  # Instance Methods
  # ========================================================================
  
  def to_mutable
    each_with_object( ::Set[] ) { |member, set|
      set << ::I8.to_mutable( member )
    }
  end
  
  
  def to_mutable_array
    each_with_object( [] ) { |member, array|
      array << ::I8.to_mutable( member )
    }
  end
  
  
  def to_h
    each_with_object( {} ) { |member, hash| hash[member] = true }
  end
  
  
  def as_json options = nil
    to_mutable_array.to_json options
    # { '$set' => to_h.as_json( options ) }
  end
  
  
  def to_yaml *args, &block
    to_mutable.to_yaml *args, &block
  end
  
end # class Set


# /Namespace
# =======================================================================

end # module I8
