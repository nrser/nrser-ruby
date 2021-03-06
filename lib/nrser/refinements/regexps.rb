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

require 'nrser/regexps/composed'
require 'nrser/ext/regexp'


# Namespace
# =======================================================================

module  NRSER
module  Regexps

# Definitions
# =======================================================================

refine ::Regexp do
  prepend NRSER::Ext::Regexp
end

refine ::Object do
  def re
    NRSER::Regexps::Composed
  end
end

# /Namespace
# =======================================================================

end # module Regexps
end # module NRSER
