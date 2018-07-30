# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require_relative './combinators'
require_relative './when'
require_relative './shape'
require_relative './collections'


# Namespace
# =======================================================================

module  NRSER
module  Types


# Definitions
# =======================================================================

# @!group Selector Type Factories
# ----------------------------------------------------------------------------

#@!method self.Selector **options
#   Factory to create {Shape} type instances that function as MongoDB-esque
#   document query against lists of Ruby objects using the standard 
#   {Enumerable#select} and related methods.
#   
#   @example
#     # Some sample data
#     
#     people = [
#       {name: "Neil", fav_color: "blue", likes: ["cat", "scotch", "computer"]},
#       {name: "Mica", fav_color: "red", like: ["cat", "beer", "dance"]},
#     ]
#     
#     # Simple value matching
#     
#     people.select( &t[ name: "Neil" ] ).map &[:name]
#     # => [ "Neil" ]
#     
#     # NOTE  1.  We're using the `t -> NRSER::Types` short-hand alias, as 
#     #           provided by `using NRSER::Types` refinement.
#     #           
#     #       2.  {NRSER::Types.[]} is a short-hand alias for 
#     #           {NRSER::Types.Selector}.
#     #           
#     #       3.  The `&[:name]` uses NRSER's {Array#to_proc} core extension.
#     #           It's equivalent to `{ |h| h[:name] }`.
#     #       
#     
#     people.select( &t[ fav_color: "red" ] ).map &[:name]
#     # => [ "Mica" ]
#     
#     # Fields that are {NRSER::Types.Bag} (think Array and Set but not Hash)
#     # match against *any* of the values
#     
#     people.select( &t[ likes: "cat" ] ).map &[:name]
#     # => [ "Neil", "Mica" ]
#     
#     # Literal arrays are treated like literals, however, and must match
#     # *exactly*
#     
#     people.select( &t[ likes: [ "cat", "computer" ] ] ).map &[:name]
#     # => []
#     
#     people.select( &t[ likes: [ "cat", "computer", "scotch" ] ] ).map &[:name]
#     # => []
#     
#     people.select( &t[ likes: [ "cat", "scotch", "computer" ] ] ).map &[:name]
#     # => ["Neil"]
#     
#     # To match against *any* of a list of terms you can construct a 
#     # {NRSER::Types.HasAny}
#     
#     people.select( &t[ likes: t.HasAny( "computer", "dance" ) ]).map &[:name]
#     # => ["Neil", "Mica"]
#     
#     # The {NRSER::Types.Has} and {.HasAny} do create types for the terms and
#     # do a `#find` against them, so you can use any of the {NRSER::Types}
#     # system in there.
#     # 
#     # Here is using a {RegExp} (which {NRSER::Types.make} wraps in a
#     # {NRSER::Types::When}):
#     
#     people.select( &t[ fav_color: /\A[bg]/ ] ).map &[:name]
#   
#   Selectors are in the very early and experimental stage, but it's something
#   I've been thinking about for a while now that suddenly just sort-of fell
#   into place.
#   
#   Eventually I want to be able to use these same selectors on SQL, MongoDB,
#   ActiveRecord, etc.
#   
#   @see  https://docs.mongodb.com/manual/tutorial/query-documents/
#         MongoDB Query Tutorial
#   @see  https://docs.mongodb.com/manual/reference/operator/query/
#         MongoDB Query and Projection Operators
# 
#   @status
#     Experimental
#   
#   @param [Hash<Object, TYPE>] pairs
#     Keys will be the keys in the resulting {.Shape} type.
#     
#     Values that are {Type} instances are used as is for the {Shape} value 
#     type. Everything else gets run through 
# 
#   @param [Hash] **options
#     Passed to {Type#initialize}.
#   
#   @return [Shape]
#   
def_type        :Selector,
  aliases:      [ :query, :[] ],
  # I don't think we need the `?` methods for Selector?
  maybe:        false,
  parameterize: :pairs,
&->( pairs, **options ) do
  shape \
    pairs.transform_values { |value|
      if value.is_a?( Type )
        value
      else
        value_type = self.When value
        self.or(
          value_type,
          (bag & has( value_type )),
          name: "{#{ value.inspect  }}"
        )
      end
    },
    **options
end # .Selector

# @!endgroup Selector Type Factories # ***************************************


# @!group Find Type Factories
# ----------------------------------------------------------------------------
# 

# @method self.Has member, **options
# 
#   Type that tests value for membership in a group object via that object's
#   `#include?` method.
#   
#   @todo
#     The "find" factories got introduced to support {.Selector}, and need 
#     improvement. They're really just stop gaps at the moment, and have 
#     already been considerably changed a few times.
#     
#     I want to eventually make selectors able to output SQL, MongoDB, etc.
#     queries, which will require we get rid of the {.Where} usage...
#   
#   @status
#     Experimental
#   
#   @param [Object] member
#     The object that needs to be included for type satisfaction.
#   
#   @param [Hash] **options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
# 
def_type        :Has,
  parameterize: :member,
  aliases:      [ :has, :includes ],
&->( member, **options ) do
  # Provide a some-what useful default name
  options[:name] ||= "Has<#{ NRSER.smart_ellipsis member.inspect, 64 }>"
  
  member_type = make member

  where( **options ) { |value|
    value.respond_to?( :find ) &&
      # value.find { |entry| member_type === entry }
      value.find( &member_type )
  }
end # .Has


#@!method self.HasAny *members, **options
#   Match values that have *any* of `members`.
#   
#   @todo
#     The "find" factories got introduced to support {.Selector}, and need 
#     improvement. They're really just stop gaps at the moment, and have 
#     already been considerably changed a few times.
#     
#     I want to eventually make selectors able to output SQL, MongoDB, etc.
#     queries, which will require we get rid of the {.Where} usage...
#   
#   @status
#     Experimental
#   
#   @param [Array<TYPE>] members
#     Resulting type will be satisfied by values in which it can `#find` any
#     entry that any of `members` is satisfied by. `members` entries that are
#     not {Type} instances will be made into them via {.make}.
#   
#   @param [Hash] **options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :HasAny,
  parameterize: :members,
  aliases:      [ :intersects ],
&->( *members, **options ) do
  options[:name] ||= \
    "HasAny<#{ NRSER.smart_ellipsis members.inspect, 64 }>"

  member_types = members.map { |m| make m }
  
  where( **options ) {
    |group| member_types.any? { |member_type| group.find &member_type }
  }
end # .HasAny

# @!endgroup Find Type Factories # *******************************************

# /Namespace
# =======================================================================

end # module Types
end # module NRSER

