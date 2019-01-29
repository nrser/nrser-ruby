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

class Vector < ::Hamster::Vector

  include NRSER::Ext::Tree
  
  # Instance Methods
  # ========================================================================
  
  def to_mutable
    each_with_object( [] ) { |entry, array|
      array << ::I8.to_mutable( entry )
    }
  end
  
  
  def as_json options = nil
    to_mutable.as_json options
  end
  
  
  def to_yaml *args, &block
    to_mutable.to_yaml *args, &block
  end
  
end # class Vector


# /Namespace
# =======================================================================

end # module I8
