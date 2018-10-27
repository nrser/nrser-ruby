# frozen_string_literal: true
# encoding: UTF-8


# Namespace
# ========================================================================

module NRSER
module Ext


# Definitions
# ========================================================================

module Symbol

  # Proxy through to built-in {#to_proc} so symbols match the {Array#to_sender}
  # API. I guess.
  # 
  # @return [Proc]
  #   Accepts one argument and sends itself to that object, returning the
  #   result.
  # 
  def to_sender; self.to_proc end
  
end # module Symbol


# Namespace
# ========================================================================

end # module Ext
end # module NRSER
