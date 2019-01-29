# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# {Candidate} is a {I8::Struct}
require 'i8/struct'


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  Described
class   Resolution


# Definitions
# =======================================================================

Candidate = I8::Struct.new value: t.Top, source: t.NonEmptyString

# /Namespace
# =======================================================================

end # class Resolution
end # module Described
end # module NRSER
