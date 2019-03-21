# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ============================================================================

### Project / Package ###

require 'nrser/booly'


# Namespace
# ========================================================================

module  NRSER
module  Ext
module  Object


# Definitions
# ========================================================================

# Calls {NRSER::Booly.truthy?} on `self`.
# 
# @return [Boolean]
# 
def truthy?
  NRSER::Booly.truthy? self
end


# Calls {NRSER::Booly.falsy?} on `self`.
# 
# @return [Boolean]
# 
def falsy?
  NRSER::Booly.falsy? self
end


# /Namespace
# ========================================================================

end # module Object
end # module Ext
end # module NRSER
