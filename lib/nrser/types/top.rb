# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require_relative './type'


# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# ========================================================================

# The top type is the universal type - all values are members.
# 
# @see https://en.wikipedia.org/wiki/Top_type
# 
class Top < NRSER::Types::Type
  NAME = '*'

  def initialize
    super name: NAME
  end

  def test? value
    true
  end
  
  def explain
    'Top'
  end

  def symbolic
    '*' # '⊤'
  end

  def has_from_s?
    true
  end

  def from_s string
    string
  end
  

  # {AnyType} instances are all equal.
  # 
  # @note
  #   `other`'s class must be {AnyType} exactly - we make no assumptions
  #   about anything that has subclasses {AnyType}.
  # 
  # @param [*] other
  #   Object to compare to.
  # 
  # @return [Boolean]
  #   `true` if `other#class` equals {AnyType}.
  # 
  def == other
    other.class == Top
  end
  
end # class Top

# Anything at all...
# 
def_type(
  :Top,
  aliases: [ :everything, :all, :any ],
) do
  # Top type gets used as a default a lot, so cache it...
  @_top_type_instance ||= Top.new
end


# /Namespace
# ========================================================================

end # module  Types
end # module  NRSER
