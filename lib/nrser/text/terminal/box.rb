# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Stdlib ###

### Deps ###

### Project / Package ###


# Refinements
# =======================================================================


# Namespace
# =======================================================================

module  NRSER
module  Text
module  Terminal


# Definitions
# =======================================================================

# @todo document Box class.
# 
class Box
  
  # Constants
  # ==========================================================================
  
  
  # Singleton Methods
  # ==========================================================================
  
  
  # Attributes
  # ==========================================================================
  
  
  # Construction
  # ==========================================================================
  
  # Instantiate a new `Box`.
  def initialize children: [], width: nil, height: nil
    @children = children
    @width = width
    @height = height
  end # #initialize
  
  
  # Instance Methods
  # ==========================================================================
  
  def layout
     
  end
  
end # class Box


# /Namespace
# =======================================================================

end # module  Terminal
end # module  Text
end # module  NRSER
