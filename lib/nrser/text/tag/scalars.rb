# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Project / Package ###

require_relative '../tag'


# Namespace
# =======================================================================

module  NRSER
module  Text
module  Tag


# Definitions
# =======================================================================

# Abstract base class for tags that wrap a *single* object.
# 
class Scalar
  
  # Mixins
  # ==========================================================================
  
  include Tag
  
  
  # Attributes
  # ==========================================================================
  
  # The tag's *only* child object.
  # 
  # @return [::Object]
  #     
  attr_reader :child
  
  
  # Construction
  # ==========================================================================
  
  # Instantiate a new `Scalar`.
  def initialize child
    @child = child
  end # #initialize
  
  
  # Instance Methods
  # ==========================================================================
  
  
end # class Scalar


class Value < Scalar; end


# /Namespace
# =======================================================================

end # module  Tag
end # module  Text
end # module  NRSER
