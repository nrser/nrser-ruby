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


# Definitions
# =======================================================================

# {::String} subclass that hangs on to the object it was created for so that we
# can be smarter about truncation and ellipsis operations.
# 
# @immutable Frozen
# 
class Strung < ::String
  
  # Attributes
  # ==========================================================================
  
  # Object this {Strung} was created from.
  # 
  # @return [::Object]
  #     
  attr_reader :source
  
  
  # Construction
  # ==========================================================================
  
  # Instantiate a new `Strung`.
  def initialize string, source:
    @source = source
    super( string )
    freeze
  end # #initialize
  
end # class Strung

# /Namespace
# =======================================================================

end # module  Text
end # module  NRSER
