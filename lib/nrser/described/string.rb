# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Extending {Object}
require_relative './object'


# Namespace
# =======================================================================

module  NRSER
module  Described


# Definitions
# =======================================================================

# Describes any old object.
# 
class String < Object
  
  # Config
  # ========================================================================
  
  subject_type ::String
  
end # class Object


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
