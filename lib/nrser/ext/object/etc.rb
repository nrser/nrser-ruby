# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# ========================================================================

module Object

  # Yield `self`. Analogous to {#tap} but returns the result of the invoked
  # block.
  def thru
    yield self
  end
  
  
  # Just an alias for `#equal?` that is easier for to remember.
  # 
  # @param [*] other
  #   Something else.
  # 
  # @return [Boolean]
  #   `true` if `self` and `other` are the same object.
  # 
  def is? other
    equal? other
  end
  
end # module Object


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER