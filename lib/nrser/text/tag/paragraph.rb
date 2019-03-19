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
module  Tag


# Definitions
# =======================================================================

# A paragraph of text.
#
class Paragraph
  
  # Mixins
  # ==========================================================================
  
  include Tag
  
  
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
  
  
end # class Paragraph


# /Namespace
# =======================================================================

end # module  Tag
end # module  Text
end # module  NRSER
