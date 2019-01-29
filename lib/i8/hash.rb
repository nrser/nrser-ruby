# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Deps ###

require "hamster"

### Project / Package ###

require 'nrser/ext/tree'

require_relative "./to_mutable"


# Namespace
# =======================================================================

module  I8


# Definitions
# =======================================================================

class Hash < ::Hamster::Hash

  include NRSER::Ext::Tree
  
  # Instance Methods
  # ========================================================================
  
  def to_mutable
    each_with_object( {} ) { |(key, value), hash|
      hash[ ::I8.to_mutable key ] = ::I8.to_mutable value
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

end # module I8
