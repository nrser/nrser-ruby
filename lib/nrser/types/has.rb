# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require_relative './where'


# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# ========================================================================


# Type that tests value for membership in a group object via that object's
# `#include?` method.
# 
# @todo
#   I think I want to get rid of {.where}... which would elevate this to
#   it's own class as a "fundamental" concept (I guess)... not so sure,
#   really. The idea of membership is pretty wide-spread and important,
#   but it's a bit a vague and inconsistently implemented things.
# 
# @param [Object] member
#   The object that needs to be included for type satisfaction.
# 
# @return [NRSER::Types::Type]
# 
def_factory   :has,
    aliases: [ :includes ] \
  do |member, **options|    
  # Provide a some-what useful default name
  options[:name] ||= "Has<#{ NRSER.smart_ellipsis member.inspect, 64 }>"
  
  where( **options ) { |value|
    value.respond_to?( :include? ) &&
      value.include?( member )
  }
end # .has


def_factory   :has_any,
    aliases:  [ :intersects ] \
do |*members, **options|
  options[:name] ||= "HasAny<#{ NRSER.smart_ellipsis members.inspect, 64 }>"

  where( **options ) {
    |group| members.any? { |member| group.include? member }
  }
end # .has_any
  

# /Namespace
# ========================================================================

end # module Types
end # module NRSER
