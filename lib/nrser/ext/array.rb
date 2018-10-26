# frozen_string_literal: true
# encoding: UTF-8

# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

# Need {NRSER.ellipsis}
require 'nrser/functions/string'

require_relative './tree'

# Sub-modules
require_relative './array/to_proc'


# Namespace
# ========================================================================

module NRSER
module Ext


# Definitions
# ========================================================================

module Array

  include Tree
  
  # Functional implementation of "rest" for arrays. Used when refining `#rest`
  # into {Array}.
  # 
  # @param [Array] array
  # 
  # @return [return_type]
  #   New array consisting of all elements after the first.
  # 
  def rest
    self[1..-1]
  end # .rest
  
  
  # A destructive partition.
  # 
  # @note
  #   Mutates self
  # 
  # @example Remove odd value from an array of integers
  #   a = [1, 2, 3, 4].be_a NRSER::Ext::Array
  #   a.extract! &:odd?
  #   #=> [1, 3]
  #   a #=> [2, 4]
  # 
  # @param [Proc<(ENTRY)->Boolean>] block
  #   Block is called with each entry, and the result is used as a boolean.
  #   
  #   If `block` responds with a truth-y value, the entry is removed from the 
  #   array and added return value.
  # 
  # @return [Array]
  #   `ENTRY` values for which `block` responded truth-y.
  # 
  def extract! &block
    extracted = []
    reject! { |entry|
      test = block.call entry
      if test
        extracted << entry
      end
      test
    }
    extracted
  end
  
  
  # Calls {NRSER.ellipsis} on `self`.
  # 
  # @todo
  #   Move definition here.
  # 
  def ellipsis *args
    NRSER.ellipsis self, *args
  end
  
  
  # To Operation Objects
  # ---------------------------------------------------------------------
  
  # Creates a new {NRSER::Message} from the array.
  # 
  # @example
  #   
  #   message = [:fetch, :x].to_message
  #   message.send_to x: 'ex', y: 'why?'
  #   # => 'ex'
  # 
  # @return [NRSER::Message]
  # 
  def to_message
    NRSER::Message.new *self
  end # #to_message
  
  alias_method :to_m, :to_message
  
  
  # Create a {Proc} that accepts a single `receiver` and provides this array's
  # entries as the arguments to `#public_send` (or `#send` if the `publicly`
  # option is `false`).
  # 
  # Equivalent to
  # 
  #   to_message.to_proc publicly: boolean
  # 
  # @example
  #   
  #   [:fetch, :x].sender.call x: 'ex'
  #   # => 'ex'
  # 
  # @param [Boolean] publicly
  #   When `true`, uses `#public_send` in liu of `#send`.
  # 
  # @return [Proc]
  # 
  def to_sender publicly: true
    to_message.to_proc publicly: publicly
  end
  
  
  # See {NRSER.chainer}.
  #
  def to_chainer publicly: true
    NRSER.chainer self, publicly: publicly
  end # #to_chainer

end # class Array


# Namespace
# ========================================================================

end # module Ext
end # module NRSER
