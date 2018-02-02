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


# @todo document NRSER::Labs::Globlin class.
class NRSER::Labs::Globlin
  
  
  # @todo document Matcher class.
  class Matcher
    def match entry
      if entry.is_a?( NRSER::Globlin )
        
      else
        
      end
    end
  end # class Matcher
  
  
  # Constants
  # ======================================================================
  
  
  # Class Methods
  # ======================================================================
  
  
  # Attributes
  # ======================================================================
  
  
  # Constructor
  # ======================================================================
  
  # Instantiate a new `NRSER:Globlin`.
  def initialize split:, ignore: nil
    @split = Array split
    
    
  end # #initialize
  
  
  # Instance Methods
  # ======================================================================
  
  def matcher_for search_string
    @split.each
  end
  
  
  def find_only! search_string
    matcher = matcher_for search_string
    
    # Search entries that have the same seg count first
    found = @seg_count_index[matcher.seg_count].find_all_map { |entry|
      matcher.match entry
    }
    
    case found.length
    when 0
      # move on..
    when 1
      return found[0]
    else
      raise TooManyError.new found
    end
    
    # Ok, try slice matches for entries with *more* segments only
    slice_matches = @seg_count_index.keys.
      select { |count| count > matcher.seg_count }.
      map { |key| @seg_count_index[key] }.
      reduce( :+ ).
      select { |entry|
        matcher.match_slice entry
      }
    
    
  end
  
end # class NRSER::Labs::Globlin
