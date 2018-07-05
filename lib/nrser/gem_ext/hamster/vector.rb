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

class Vector
  
  include NRSER::Ext::Tree
  
  # Instance Methods
  # ========================================================================
  
  def to_mutable
    each_with_object( [] ) { |entry, array|
      array << Hamster.to_mutable( entry )
    }
  end
  
  
  def as_json options = nil
    to_mutable.as_json options
  end
  
  
  def to_yaml *args, &block
    to_mutable.to_yaml *args, &block
  end
  
end # class Hash


# /Namespace
# =======================================================================

end # module Hamster
