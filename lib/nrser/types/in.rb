# encoding: UTF-8
# frozen_string_literal: true

module NRSER::Types
  
  # Type that tests value for membership in a group object via that object's
  # `#include?` method.
  # 
  # @param [#include?] group
  #   `#include?` will be called on this value to determine type membership.
  # 
  # @return [NRSER::Types::Type]
  # 
  def_factory(
    :in,
    aliases: [ :member_of ],
  ) do |group, **options|
    where( name: "In<#{ group }>", **options ) { |value|
      group.include? value
    }
  end # .in
  
end # module NRSER::Types
