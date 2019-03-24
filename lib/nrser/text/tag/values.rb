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

class Values < ::Hash
  
  # Mixins
  # ==========================================================================
  
  include Tag
  
  
  # Construction
  # ==========================================================================
  
  # Instantiate a new {Section}.
  def initialize **values
    super()
    replace values
    freeze
  end # #initialize
  
  
  # Instance Methods
  # ==========================================================================
  
end # class Section


# /Namespace
# =======================================================================

end # module  Tag
end # module  Text
end # module  NRSER
