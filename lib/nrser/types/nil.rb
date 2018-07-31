# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require_relative './is'


# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# ========================================================================

# @!group Nil Type Factories
# ----------------------------------------------------------------------------

#@!method self.Nil **options
#   Type for `nil`; itself and only.
#   
#   @todo
#     Should we have a `#from_s` that converts the empty string to `nil`?
#     
#     Kind-of seems like we would want that to be a different types so that
#     you can have a Nil type that is distinct from the empty string in
#     parsing, but also have a type that accepts the empty string and coverts
#     it to `nil`?
#     
#     Something like:
#     
#         type = t.empty | t.non_empty_str
#         type.from_s ''
#         # => nil
#         type.from_s 'blah'
#         # => 'blah'
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :Nil,
  aliases:      [ :null ],
  # `.Nil?` would not make any sense...
  maybe:        false,
&->( **options ) do
  is nil, **options
end # .Nil

# @!endgroup Nil Type Factories # ********************************************


# /Namespace
# ========================================================================

end # module Types
end # module NRSER
