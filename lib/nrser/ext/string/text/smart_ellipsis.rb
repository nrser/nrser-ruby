# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

# Using {Char::ELLIPSIS}
require 'nrser/char'

# Using {Ext::Elidable#ellipsis}
require_relative './ellipsis'


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# =======================================================================

module String
  
  # Instance Methods
  # ========================================================================

 # Try to do "smart" job adding ellipsis to the middle of strings by
  # splitting them by a separator `split` - that defaults to `, ` - then
  # building the result up by bouncing back and forth between tokens at the
  # beginning and end of the string until we reach the `max` length limit.
  # 
  # Intended to be used with possibly long single-line strings like
  # `#inspect` returns for complex objects, where tokens are commonly
  # separated by `, `, and producing a reasonably nice result that will fit
  # in a reasonable amount of space, like `rspec` output (which was the
  # motivation).
  # 
  # If `string` is already less than `max` then it is just returned.
  # 
  # If `string` doesn't contain `split` or just the first and last tokens
  # alone would push the result over `max` then falls back to
  # {NRSER.ellipsis}.
  # 
  # If `max` is too small it's going to fall back nearly always... around
  # `64` has seemed like a decent place to start from screwing around on
  # the REPL a bit.
  # 
  # @pure
  #   Return value depends only on parameters.
  # 
  # @status
  #   Experimental
  # 
  # @param [String] string
  #   Source string.
  # 
  # @param [Fixnum] max
  #   Max length to allow for the output string. Result will usually be
  #   *less* than this unless the fallback to {NRSER.ellipsis} kicks in.
  # 
  # @param [String] omission
  #   The string to stick in the middle where original contents were
  #   removed. Defaults to the unicode ellipsis since I'm targeting the CLI
  #   at the moment and it saves precious characters.
  # 
  # @param [String] split
  #   The string to tokenize the `string` parameter by. If you pass a
  #   {Regexp} here it might work, it might loop out, maybe.
  # 
  # @return [String]
  #   String of at most `max` length with the middle chopped out if needed
  #   to do so.
  # 
  def smart_ellipsis max, omission: Char::ELLIPSIS.char, split: ', '
    return self unless length > max
    
    unless include? split
      return n_x.ellipsis max, omission: omission
    end
    
    tokens = self.split split
    
    char_budget = max - omission.length
    start = tokens[0] + split
    finish = tokens[tokens.length - 1]
    
    if start.length + finish.length > char_budget
      return n_x.ellipsis max, omission: omission
    end
    
    next_start_index = 1
    next_finish_index = tokens.length - 2
    next_index_is = :start
    next_index = next_start_index
    
    while (
      start.length +
      finish.length +
      tokens[next_index].length +
      split.length
    ) <= char_budget do
      if next_index_is == :start
        start += tokens[next_index] + split
        next_start_index += 1
        next_index = next_finish_index
        next_index_is = :finish
      else # == :finish
        finish = tokens[next_index] + split + finish
        next_finish_index -= 1
        next_index = next_start_index
        next_index_is = :start
      end
    end
    
    start + omission + finish
    
  end # .smart_ellipsis

end # module String


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
