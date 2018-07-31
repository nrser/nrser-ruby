# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require 'nrser/core_ext/hash'

require_relative './combinators'
require_relative './attributes'
require_relative './tuples'


# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# =======================================================================

# @!group Pairs Type Factories
# ----------------------------------------------------------------------------


#@!method self.ArrayPair key: self.Top, value: self.Top, **options
#   Type for key/value pairs encoded as a {.Tuple} ({::Array}) of length 2.
#   
#   @param [TYPE] key
#     Key type. Made into a type by {NRSER::Types.make} if it's not already.
#   
#   @param [TYPE] value
#     Value type. Made into a type by {NRSER::Types.make} if it's not already.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :ArrayPair,
  default_name: false,
  parameterize: [ :key, :value ],
&->( key: self.Top, value: self.Top, **options ) do
  tuple \
    key,
    value,
    **options
end # .ArrayPair


# @!method self.HashPair key: self.Top, value: self.Top, **options
# 
#   Type whose members are single a key/value pairs encoded as {::Hash} instances 
#   with a single entry (`::Hash#length==1`).
#   
#   @param [TYPE] key
#     Key type. Made into a type by {NRSER::Types.make} if it's not already.
#   
#   @param [TYPE] value
#     Value type. Made into a type by {NRSER::Types.make} if it's not already.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
# 
def_type        :HashPair,
  default_name: false,
  parameterize: [ :key, :value ],
&->( key: self.Top, value: self.Top, **options ) do
  key = self.make key
  value = self.make value

  options[:name] ||= "Hash<(#{ key.name }, #{ value.name })>"
  
  options[:symbolic] ||= "(#{ key.symbolic }=>#{ value.symbolic })"
  
  intersection \
    self.Hash( keys: key, values: value ),
    self.Length( 1 ),
    **options
end # .HashPair


#@!method self.Pair key: self.Top, value: self.Top, **options
#   A key/value pair, which can be encoded as an Array of length 2 or a
#   Hash of length 1.
#   
#   @param [TYPE] key
#     Key type. Made into a type by {NRSER::Types.make} if it's not already.
#   
#   @param [TYPE] value
#     Value type. Made into a type by {NRSER::Types.make} if it's not already.
# 
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :Pair,
  default_name: false,
  parameterize: [ :key, :value ],
&->( key: self.Top, value: self.Top, **options ) do
  key = self.make key
  value = self.make value

  options[:name] ||= if key == self.Top && value == self.Top
    "Pair"
  else
    "Pair<#{ key.name }, #{ value.name }>"
  end

  options[:symbolic] ||= "(#{ key.symbolic }, #{ value.symbolic })"
  
  union \
    self.ArrayPair( key: key, value: value ),
    self.HashPair(  key: key, value: value ),
    **options
end # .Pair

# @!endgroup Pairs Type Factories # ******************************************


# /Namespace
# ========================================================================

end # module  NRSER
end #module  Types
