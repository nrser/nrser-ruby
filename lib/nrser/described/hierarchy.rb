# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------


# Refinements
# =======================================================================


# Namespace
# =======================================================================

module  NRSER
module  Described


# Definitions
# =======================================================================

# @todo document Hierarchy class.
# 
class Hierarchy
  
  # Mixins
  # ========================================================================
  
  include Enumerable
  
  
  # Construction
  # ========================================================================
  
  # Instantiate a new `Hierarchy`.
  def initialize
    @storage = []
  end # #initialize
  
  
  # Instance Methods
  # ========================================================================
  
  def last
    @storage.last
  end
  
  
  def add described
    @storage << described
  end
  
  
  def each &block
    @storage.reverse_each &block
  end
  
  
  def touch described
    @storage.delete described
    @storage << described
  end
  
  
  def find_by_human_name human_name, touch: true
    find do |described|
      if described.class.human_names.include? human_name
        touch( described ) if touch
        true
      end
    end
  end
  
  
  def find_by_human_name! human_name, touch: true
    find_by_human_name( human_name, touch: touch ).tap { |described|
      if described.nil?
        raise NRSER::NotFoundError.new \
          "Could not find described instance in parent tree with human name",
          human_name.inspect
      end
    }
  end
  
  
end # class Hierarchy


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
