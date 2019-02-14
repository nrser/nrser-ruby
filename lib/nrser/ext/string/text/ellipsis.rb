# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

### Project / Package ###

# Using {Ext::Elidable#ellipsis}
require 'nrser/ext/elidable'


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# =======================================================================

module String
  
  include Elidable

end # module String


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
