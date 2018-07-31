# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require_relative './combinators'
require_relative './strings'


# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# =======================================================================

# @!group Label Type Factories
# ----------------------------------------------------------------------------

#@!method self.Label **options
#   A label is a non-empty {String} or {Symbol}.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :Label,
&->( **options ) do
  union non_empty_str, non_empty_sym, name: name, **options
end # .Label

# @!endgroup Label Type Factories # ******************************************


# /Namespace
# ========================================================================

end # module Types
end # module NRSER

