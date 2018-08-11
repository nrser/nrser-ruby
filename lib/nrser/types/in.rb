# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/errors/type_error'

# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# ========================================================================

# @!group In Type Factories
# ----------------------------------------------------------------------------

#@!method self.In group, **options
#   Type that tests value for membership in a group object via that object's
#   `#include?` method.
#   
#   @todo
#     I think I want to get rid of {.where}... which would elevate this to
#     it's own class as a "fundamental" concept (I guess)... not so sure,
#     really. The idea of membership is pretty wide-spread and important,
#     but it's a bit a vague and inconsistently implemented things.
#   
#   @param [#include?] group
#     `#include?` will be called on this value to determine type membership.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
#   @raise [NRSER::TypeError]
#     If `group` doesn't respond to `#include?`.
# 
def_type        :In,
  aliases:      [ :member_of ],
  from_s:       ->( s ) { s },
  default_name: ->( group, **options ) {
                  "In<#{ NRSER.smart_ellipsis group.inspect, 64 }>"
                },
  parameterize: :group,
&->( group, **options ) do
  unless group.respond_to? :include?
    raise NRSER::TypeError,
      "In `group` must respond to `:include?`",
      group: group
  end

  # TODO  This is a step in the right direction (from anon {Proc}) but I
  #       now think what we really want is 
  #       
  #           where group, :include?
  #       
  self.Where group.method( :include? ), **options
end # .In

# @!endgroup In Type Factories # *********************************************


# /Namespace
# ========================================================================

end # module Types
end # module NRSER

