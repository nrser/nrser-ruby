# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# ----------------------------------------------------------------------------

require 'set'

# Deps
# -----------------------------------------------------------------------

require 'hamster'

require 'nrser/ext/tree'


# Namespace
# =======================================================================

module  Hamster


# Definitions
# =======================================================================

class Set
  
  # Instance Methods
  # ========================================================================
  
  def to_mutable
    each_with_object( ::Set[] ) { |member, set|
      set << Hamster.to_mutable( member )
    }
  end
  
  
  def to_mutable_array
    each_with_object( [] ) { |member, array|
      array << Hamster.to_mutable( member )
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
  
end # class Hash


# /Namespace
# =======================================================================

end # module Hamster
