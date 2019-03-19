# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Stdlib ###

### Deps ###

### Project / Package ###


# Namespace
# =======================================================================

module  NRSER
module  Text
module  Tag


# Definitions
# =======================================================================

# Abstract base class for a very simple, target-agnostic tagging system for
# structured text.
#
class Section
  
  # Mixins
  # ==========================================================================
  
  include Tag
  
  
  # Attributes
  # ==========================================================================
  
  # TODO document `name` attribute.
  # 
  # @return [attr_type]
  #   
  attr_reader :blocks
  
  
  # Construction
  # ==========================================================================
  
  # Instantiate a new {Section}.
  def initialize *blocks
    super()
    @blocks = blocks.freeze
  end # #initialize
  
  
  # Instance Methods
  # ==========================================================================
  
  
end # class Section


# /Namespace
# =======================================================================

end # module  Tag
end # module  Text
end # module  NRSER
