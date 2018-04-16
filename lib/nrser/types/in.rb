# encoding: UTF-8
# frozen_string_literal: true

module NRSER::Types
  
  # Type that tests value for membership in a group object via that object's
  # `#include?` method.
  # 
  # @todo
  #   I think I want to get rid of {.where}... which would elevate this to
  #   it's own class as a "fundamental" concept (I guess)... not so sure,
  #   really. The idea of membership is pretty wide-spread and important,
  #   but it's a bit a vague and inconsistently implemented things.
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
    unless group.respond_to? :include?
      raise ArgumentError,
        "In `group` must respond to `:include?`, found #{ group.inspect }"
    end
    
    # TODO  This will get really unwieldy for big groups...
    options[:name] ||= "In<#{ group }>"
    
    # Unless a `from_s` is provided, just use the identity
    options[:from_s] ||= ->( s ) { s }
    
    where( **options ) { |value| group.include? value }
  end # .in
  
end # module NRSER::Types
