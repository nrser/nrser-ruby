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


# Declarations
# =======================================================================

module NRSER::Labs; end



# Definitions
# =======================================================================

# A very basic index data structure that
class NRSER::Labs::Index
  
  # Attributes
  # ======================================================================
  
  
  # Constructor
  # ======================================================================
  
  # Instantiate a new `NRSER::Index`.
  def initialize entries = nil, sort: false, &indexer
    @indexer = indexer
    @hash = Hash.new { |hash, key| hash[key] = Set.new }
    
    add( *entries ) if entries
  end # #initialize
  
  
  # Instance Methods
  # ======================================================================
  
  def key_for entry
    @indexer.call entry
  end
  
  
  def keys
    Set.new @hash.keys
  end
  
  
  def values
    @hash.values.reduce :+
  end
  
  
  def [] key
    @hash[key]
  end
  
  
  def add *entries
    entries.each do |entry|
      @hash[key_for( entry )].add entry
    end
    
    self
  end
  
  
  def remove *entries
    entries.each do |entry|
      @hash[key_for( entry )].remove entry
    end
    
    self
  end
  
end # class NRSER::Index
