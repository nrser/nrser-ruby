# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require_relative './is'
require_relative './is_a'


# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# ========================================================================

# @!group Symbol Type Factories
# ----------------------------------------------------------------------------

#@!method self.Symbol **options
#   {Symbol} instances. Load from strings as you would expect {::String#to_sym}.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :Symbol,
  aliases:      [ :sym ],
  from_s:       :to_sym.to_proc,
&->( **options ) do
  self.IsA ::Symbol, **options
end # .Symbol


#@!method self.EmptySymbol **options
#   Exactly `:''`.
#   
#   Pretty much just exists for use in {.NonEmptySymbol}, which pretty much
#   just exists for use in {.Label}, which actually has some use ;)
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :EmptySymbol,
  aliases:      [ :empty_sym ],
  from_s:       :to_sym.to_proc,
&->( **options ) do
  self.Is :'', **options
end # .EmptySymbol


#@!method self.NonEmptySymbol **options
#   A {Symbol} that is *not* `:''`.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :NonEmptySymbol,
  aliases:      [ :non_empty_sym ],
&->( **options ) do
  self.Intersection \
    self.Symbol,
    !self.EmptySymbol,
    **options
end # .NonEmptySymbol

# @!endgroup Symbol Type Factories # *****************************************


# /Namespace
# ========================================================================

end # module Types
end # module NRSER
