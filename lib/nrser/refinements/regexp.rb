# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/ext/regexp'


# Namespace
# =======================================================================

module  NRSER
module  Refinements

# Definitions
# =======================================================================


# @todo document Regexp module.
module Regexp
  
  refine ::Regexp do
    prepend NRSER::Ext::Regexp
  end
  
end # module Regexp

# /Namespace
# =======================================================================

end # module Refinements
end # module NRSER
