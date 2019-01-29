# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

## Stdlib ##

require 'set'


# Definitions
# =======================================================================

module I8

  def self.to_mutable obj
    if obj.respond_to? :to_mutable
      obj.to_mutable
      
    elsif ::Array === obj
      obj.map { |e| to_mutable e }
      
    elsif ::Hash === obj
      obj.each_with_object( {} ) { |(k, v), h|
        h[ to_mutable k ] = to_mutable v
      }
      
    elsif ::SortedSet === obj
      ::SortedSet.new obj.map { |m| to_mutable m }
      
    elsif ::Set === obj
      ::Set.new obj.map { |m| to_mutable m }
      
    else
      obj
      
    end
  end # .to_mutable
  
end # module I8

