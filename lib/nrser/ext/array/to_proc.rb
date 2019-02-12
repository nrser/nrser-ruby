# frozen_string_literal: true
# encoding: UTF-8

# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require 'nrser/message'


# Namespace
# ========================================================================

module NRSER
module Ext


# Definitions
# ========================================================================

module Array
    
  # Returns a lambda that calls accepts a single arg and calls either:
  # 
  # 1.  `#[self.first]` if this array has only one entry.
  # 2.  `#dig( *self )` if this array has more than one entry.
  # 
  # @example
  #   list = [{id: 1, name: "Neil"}, {id: 2, name: "Mica"}]
  #   list.assoc_by &[:id]
  #   # =>  {
  #   #       1 => {id: 1, name: "Neil"},
  #   #       2 => {id: 2, name: "Mica"},
  #   #     }
  # 
  # @return [Proc]
  #   Lambda proc that accepts a single argument and calls `#[]` or `#dig with 
  #   this array's contents as the arguments.
  # 
  def to_proc
    method_name = case count
    when 0
      raise NRSER::CountError.new \
        "Can not create getter proc from empty array",
        value: self,
        expected: '> 0',
        count: count
    when 1
      :[]
    else
      :dig
    end
      
    NRSER::Message.new( method_name, *self ).to_proc
  end # #to_proc
  
end # module Array


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
