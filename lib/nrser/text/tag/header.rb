# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Stdlib ###

### Deps ###

### Project / Package ###

require_relative '../tag'


# Namespace
# =======================================================================

module  NRSER
module  Text
class   Tag


# Definitions
# =======================================================================

# A header.
#
class Header < Tag
  
  # Attributes
  # ==========================================================================
  
  # TODO document `name` attribute.
  # 
  # @return [attr_type]
  #   
  attr_reader :fragments
  
  
  # Construction
  # ==========================================================================
  
  # Instantiate a new {Paragraph}.
  def initialize *fragments
    @fragments = fragments.freeze
  end # #initialize
  
  
  # Instance Methods
  # ==========================================================================
  
  
end # class Header


# /Namespace
# =======================================================================

end # class   Tag
end # module  Text
end # module  NRSER
