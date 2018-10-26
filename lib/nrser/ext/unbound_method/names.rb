# frozen_string_literal: true
# encoding: UTF-8


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# ========================================================================

module UnboundMethod
  
  # Instance Methods
  # ========================================================================
  
  def full_name
    # Need to string parse {#to_s}?!
    raise NotImplementedError, "Haven't done this one yet"
  end
  
  alias_method :to_summary, :full_name
  
end # module UnboundMethod


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
