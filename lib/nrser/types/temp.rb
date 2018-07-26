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
  # @param [Object] member
  #   The object that needs to be included for type satisfaction.
  # 
  # @return [NRSER::Types::Type]
  # 
  def_factory(
    :has,
    aliases: [ :includes ],
  ) do |member, **options|    
    # Provide a some-what useful default name
    options[:name] ||= "Has<#{ NRSER.smart_ellipsis member.inspect, 64 }>"
    
    where( **options ) { |value|
      value.respond_to?( :include? ) &&
        value.include?( member )
    }
  end # .in
  
end # module NRSER::Types
