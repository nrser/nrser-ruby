# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Deps
# -----------------------------------------------------------------------

require 'hamster'

require 'nrser/ext/tree'


# Namespace
# =======================================================================

module  Hamster


# Definitions
# =======================================================================

class Hash
  
  include NRSER::Ext::Tree
  
  # Instance Methods
  # ========================================================================
  
  def to_mutable
    each_with_object( {} ) { |(key, value), hash|
      hash[ Hamster.to_mutable key ] = Hamster.to_mutable value
    }
  end
  
  
  def as_json options = nil
    to_h.as_json options
  end
  
  
  def to_yaml *args, &block
    to_mutable.to_yaml *args, &block
  end
  
end # class Hash


# /Namespace
# =======================================================================

end # module Hamster
