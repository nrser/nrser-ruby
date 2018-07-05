require 'set'

require 'hamster'
require_relative './hamster/hash'
require_relative './hamster/vector'
require_relative './hamster/set'
require_relative './hamster/sorted_set'

module Hamster
  # def self.regrow each_pair: ::Hash, each_index: ::Array, each:
  
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
  
end
