# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# ========================================================================

module  NRSER
module  Ext
module  String


# Definitions
# =======================================================================

# Split text at whitespace to fit in line length. Lifted from Rails'
# ActionView.
# 
# @see http://api.rubyonrails.org/classes/ActionView/Helpers/TextHelper.html#method-i-word_wrap
# 
# @param [Integer] line_width
#   Line with in number of character to wrap at.
# 
# @param [String] break_sequence
#   String to join lines with.
# 
# @return [String]
#   Word-wrapped string.
# 
def word_wrap line_width: 80, break_sequence: "\n"
  split("\n").collect! do |line|
    line.length > line_width ? line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1#{break_sequence}").strip : line
  end * break_sequence
end # .word_wrap


# /Namespace
# ========================================================================

end # module String
end # module Ext
end # module NRSER
