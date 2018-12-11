# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Stdlib
# ------------------------------------------------------------------------

# Deps
# ------------------------------------------------------------------------

# Project / Package
# ------------------------------------------------------------------------

require 'nrser/regexp/composed'


# Namespace
# ============================================================================

module  NRSER
module  Ext


# Definitions
# ============================================================================

# @todo document Regexp module.
module Regexp
  
  # Instance Methods
  # ========================================================================
  
  def full?
    source.start_with?( '\A' ) && source.end_with?( '\z' )
  end
  
  
  def fragment?
    !( source.start_with?( '\A' ) || source.end_with?( '\z' ) )
  end
  
  
  def to_full_source
    NRSER::Regexp::Composed.to_full_source self
  end
  
  
  def to_full
    if n_x.full?
      self
    else
      self.class.new n_x.to_full_source, options
    end
  end
  
  
  def to_fragment_source
    NRSER::Regexp::Composed.to_fragment_source self
  end
  
  
  def to_fragment
    if n_x.fragment?
      self
    else
      self.class.new n_x.to_fragment_source, options
    end
  end
  
  
  def join *others
    NRSER::Regexp::Composed.join self, *others,
      full: n_x.full?,
      options: options
  end
  
  
  def or *others
    NRSER::Regexp::Composed.or self, *others,
      full: n_x.full?,
      options: options
  end
  
  
  def + other
    n_x.join other
  end
  
  
  def | other
    n_x.or other
  end
  
end # module Regexp

# /Namespace
# ============================================================================

end # module Ext
end # module NRSER
