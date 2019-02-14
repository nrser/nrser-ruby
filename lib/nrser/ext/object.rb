# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

# Submodules
require_relative './object/as'
require_relative './object/booly'
require_relative './object/etc'
require_relative './object/lazy_var'


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# ========================================================================

# Extensions for {::Object}.
# 
module Object
  refine ::Object do
    prepend Ext::Object
  end
end # module Module


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
