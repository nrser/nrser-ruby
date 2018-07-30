# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------
require_relative './combinators'
require_relative './responds'
require_relative './is_a'


# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# =======================================================================

# @!group Collection Type Factories
# ----------------------------------------------------------------------------

#@!method self.Vector **options
#   An "array-like" {Enumerable} that responds to `#each_index` and 
#   `#slice` / `#[]`.
#   
#   @param [Hash] **options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :Vector,
  aliases:      [ :array_like ],
&->( **options ) do
  intersection \
    is_a( Enumerable ),
    respond_to( :each_index ),
    respond_to( :slice ),
    respond_to( :[] ),
    name: name,
    **options
end # .Vector


#@!method self.Map **options
#   A "hash-like" {Enumerable} that responds to `#each_pair` and `#[]`.
#   
#   @param [Hash] **options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :Map,
  aliases:      [ :hash_like, :assoc ],
&->( **options ) do
  intersection \
    is_a( Enumerable ),
    respond_to( :each_pair ),
    respond_to( :[] ),
    name: name,
    **options
end # .Map


#@!method self.Bag **options
#   An {Enumerable} that does **not** respond to `#each_pair`.
#   
#   Meant to encompass {Set}, {Array} and the like *without* {Hash} and other
#   associative containers.
#   
#   Elements may or may not be indexed.
#   
#   @param [Hash] **options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :Bag,
&->( **options ) do
  intersection \
    is_a( Enumerable ),
    self.not( respond_to( :each_pair ) ),
    name: name,
    **options
end # .Bag


#@!method self.Tree **options
#   Either a {.Vector} or {.Map} - {Enumerable} collections with indexed
#   elements that work with the {NRSER} "tree" functions.
#   
#   @param [Hash] **options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :Tree,
&->( **options ) do
  union \
    array_like,
    hash_like,
    name: name,
    **options
end # .Tree

# @!endgroup Collection Type Factories # *************************************


# /Namespace
# ========================================================================

end # module Types
end # module NRSER

