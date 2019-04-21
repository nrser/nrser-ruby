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
class Sequence < ::Array
  
  # Mixins
  # ==========================================================================
  
  include Tag
  
end # class Sequence


class Paragraph < Sequence; end


class Header < Sequence
  
  # Optional override of header level. Should be a non-negative {::Integer}
  # (unless it's `nil`, which means use the default automatic leveling).
  # 
  # @return [nil | Integer]
  #     
  attr_reader :level
  
  def initialize *fragments, level: nil
    @level = level
    super( fragments )
  end
end


class Section < Sequence; end


# /Namespace
# =======================================================================

end # module  Tag
end # module  Text
end # module  NRSER
