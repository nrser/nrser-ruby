# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

# Submods
require_relative './enumerable/associate'
require_relative './enumerable/find'
require_relative './enumerable/merge_by'
require_relative './enumerable/pair'
require_relative './enumerable/slash_map'
require_relative './enumerable/slice'


# Namespace
# ========================================================================

module NRSER
module Ext


# Definitions
# ========================================================================

# Instance methods to extend {Enumerable}.
# 
module Enumerable
  
  # Create an {Enumerator} that iterates over the "values" of this {Enumerable}.
  # If it responds to `#each_value` than we return that. Otherwise, we
  # return `#each_entry`.
  # 
  # @return [Enumerator]
  # 
  # @raise [ArgumentError]
  #   If `self` doesn't respond to `#each_value` or `#each_entry`.
  # 
  def enumerate_as_values
    # NRSER.match enum,
    #   t.respond_to(:each_value), :each_value.to_proc,
    #   t.respond_to(:each_entry), :each_entry.to_proc
    # 
    if respond_to? :each_value
      each_value
    elsif respond_to? :each_entry
      each_entry
    else
      raise ArgumentError.new erb binding, <<-END
        Expected {Enumerable} to respond to :each_value or :each_entry, found:
        
            <%= inspect %>
        
      END
    end
  end # #enumerate_as_values
  
  
  # Count entries by the value returned when they are passed to the block.
  #
  # @example Count array entries by class
  #   require 'nrser/ext/enumerable'
  #   
  #   [1, 2, :three, 'four', 5, :six].n_x.count_by &:class
  #   #=> {Fixnum=>3, Symbol=>2, String=>1}
  # 
  # @param [Proc<(E)=>C>] block
  #   Block mapping entries to the group to count them in.
  # 
  # @return [Hash{C=>Integer}]
  #   Hash mapping groups to positive integer counts.
  # 
  def count_by &block
    each_with_object( Hash.new 0 ) do |entry, hash|
      hash[ block.call entry ] += 1
    end
  end # #count_by

  
end # module Enumerable


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
