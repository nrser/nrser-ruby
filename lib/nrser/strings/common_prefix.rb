# encoding: UTF-8
# frozen_string_literal: true


# Refinements
# ============================================================================

require 'nrser/ext/enumerable'
using NRSER::Ext::Enumerable


# Namespace
# =======================================================================

module  NRSER


# Definitions
# =======================================================================

module Strings
  
  # Find the common prefix 
  def self.common_prefix *strings
    strings.flatten!
    
    raise ArgumentError.new("argument can't be empty") if strings.empty?
    
    strings.sort!
    
    index = 0
    max_index = [ strings.first.length, strings.last.length ].min
    
    while strings.first[ index ] == strings.last[ index ] && index < max_index
      index += 1
    end
    
    strings.first[ 0...index ]
  end # .common_prefix
  
  
  # Can't refine mixins, so can't refine in {::Enumerable#deep_each}... this
  # could be done recursively of course, but I'm not even sure if it's wanted /
  # worth it to generalize like this...
  # def self.common_prefix *enumerables_or_strings
  #   prefix = nil
    
  #   enumerables_or_strings.deep_each do |string|
  #     string = string.to_s unless string.is_a?( ::String )
      
  #     if prefix.nil?
  #       prefix = string
  #     else
  #       index = 0
        
  #       max_index = [ prefix.length, string.length ].min
        
  #       while prefix[ index ] == string[ index ] && index < max_index
  #         index += 1
  #       end
        
  #       return '' if index == 0
        
  #       prefix = prefix[ 0...index ]
  #     end
  #   end
    
  #   if prefix.nil?
  #     raise ArgumentError.new \
  #       "No string found",
  #       args: enumerables_or_strings
  #   else
  #     prefix
  #   end
  # end
  
end # module Strings


# /Namespace
# =======================================================================

end # module NRSER
