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


# Definitions
# =======================================================================

# 
class NRSER::RSpex::Described
  
  # Constants
  # ======================================================================
  
  
  # Class Methods
  # ======================================================================
  
  
  # Attributes
  # ======================================================================
  
  
  # Constructor
  # ======================================================================
  
  # Instantiate a new `NRSER::RSpex::Described`.
  def initialize **metadata
    
  end # #initialize
  
  
  # Instance Methods
  # ======================================================================
  
  
end # class NRSER::RSpex::Described




# @todo document NRSER::RSpex::Described::Class class.
class NRSER::RSpex::Described::Class < NRSER::RSpex::Described
  def initialize class:
  end
  
  
  def location
    # Get a reasonable file and line for the class
    file, line = klass.
      # Get an array of all instance methods, excluding inherited ones
      # (the `false` arg)
      instance_methods( false ).
      # Add `#initialize` since it isn't in `#instance_methods` for some
      # reason
      <<( :initialize ).
      # Map those to their {UnboundMethod} objects
      map { |sym| klass.instance_method sym }.
      # Toss any `nil` values
      compact.
      # Get the source locations
      map( &:source_location ).
      # Get the first line in the shortest path
      min_by { |(path, line)| [path.length, line] }
      
      # Another approach I thought of... (untested)
      # 
      # Get the path
      # # Get frequency of the paths
      # count_by { |(path, line)| path }.
      # # Get the one with the most occurrences
      # max_by { |path, count| count }.
      # # Get just the path (not the count)
      # first
  end
  
  
  def to_desc
    
  end
end # class NRSER::RSpex::Described::Class




# Post-Processing
# =======================================================================
