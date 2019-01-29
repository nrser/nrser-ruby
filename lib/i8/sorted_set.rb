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

# @todo document SortedSet class.
# 
class SortedSet < ::Hamster::SortedSet
  
  # Instance Methods
  # ========================================================================
  
  def to_mutable
    each_with_object( ::SortedSet[] ) { |member, set|
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
  
end # class SortedSet

# /Namespace
# =======================================================================

end # module I8
