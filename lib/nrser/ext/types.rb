# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

# Submodules
require 'nrser/types'

# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# ========================================================================

# Extensions for {::Object}.
# 
module Types

  def t *args
    if args.empty?
      NRSER::Types
    else
      NRSER::Types.make *args
    end
  end
  
  def to_type
    NRSER::Types.make self, try_to_type: false
  end

end # module Types


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
