# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

# {NRSER::Ext::Tree} is mixed in as well.
require_relative './tree'

# Submodules
require_relative './hash/transform'


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# ========================================================================

# Extensions for {::Hash}.
# 
module Hash

  include Tree
  
end # module Hash


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER

