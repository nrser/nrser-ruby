# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/functions/text'
require 'nrser/strings/common_prefix'


# Namespace
# ========================================================================

module  NRSER
module  Ext
module  String


# Definitions
# =======================================================================

# Constants
# ----------------------------------------------------------------------------

### @!group Indentation Constants ###

INDENT_RE = /\A[\ \t]*/

DEFAULT_INDENT_TAG_MARKER     = "\x1E"
DEFAULT_INDENT_TAG_SEPARATOR  = "\x1F"

### @!endgroup Indentation Constants ###


# Instance Methods
# ----------------------------------------------------------------------------

### @!group Indentation Instance Methods ###

# Find the common indent over the {::String#lines} of the instance.
# 
# @return [::String]
# 
def find_indent
  Strings.common_prefix \
    lines.map { |line| line[ Ext::String::INDENT_RE ] }
end


# Is this string indented?
# 
# @return [Boolean]
# 
def indented?
  !n_x.find_indent.empty?
end


def dedent ignore_whitespace_lines: true, return_lines: false
  
  return self if empty?
  
  all_lines = lines
  
  indent_significant_lines = if ignore_whitespace_lines
    all_lines.reject { |line| line.n_x.whitespace? }
  else
    all_lines
  end
  
  indent = indent_significant_lines.join.n_x.find_indent
  
  return self if indent.empty?
  
  dedented_lines = all_lines.map { |line|
    if line.start_with? indent
      line[ indent.length..-1 ]
    elsif line.end_with? "\n"
      "\n"
    else
      ""
    end
  }
  
  if return_lines
    dedented_lines
  else
    dedented_lines.join
  end
end # .dedent


# I like the name {#dedent}, but this one seems more popular at large. Simply
# proxies to {#dedent}.
# 
def deindent *args
  n_x.dedent *args
end

# adapted from active_support 4.2.0
# 
# <https://github.com/rails/rails/blob/7847a19f476fb9bee287681586d872ea43785e53/activesupport/lib/active_support/core_ext/string/indent.rb>
#
def indent  amount = 2,
            *active_support_args,
            indent_string: nil,
            indent_empty_lines: false,
            skip_first_line: false
  
  unless active_support_args.empty?
    indent_string = active_support_args[ 0 ]
    indent_empty_lines = active_support_args[ 1 ] || false
  end
  
  if skip_first_line
    first_line, rest = split "\n", 2
    
    return first_line if rest.nil?
    
    first_line +
      "\n" + 
      rest.n_x.indent(
        amount, 
        indent_string: indent_string,
        indent_empty_lines: indent_empty_lines,
        skip_first_line: false,
      )
      
  else
    indent_string = indent_string || self[/^[ \t]/] || ' '
    re = indent_empty_lines ? /^/ : /^(?!$)/
    gsub re, indent_string * amount
    
  end
end # #indent


# Tag each line of `text` with special marker characters around it's leading
# indent so that the resulting text string can be fed through an
# interpolation process like ERB that may inject multi-line strings and the
# result can then be fed through {NRSER.indent_untag} to apply the correct
# indentation to the interpolated lines.
# 
# Each line of `text` is re-formatted like:
# 
#     "<marker><leading_indent><separator><line_without_leading_indent>"
# 
# `marker` and `separator` can be configured via keyword arguments, but they
#  default to:
# 
# -   `marker` - {NRSER::INDENT_TAG_MARKER}, the no-printable ASCII
#     *record separator* (ASCII character 30, "\x1E" / "\u001E").
#     
# -   `separator` - {NRSER::INDENT_TAG_SEPARATOR}, the non-printable ASCII
#     *unit separator* (ASCII character 31, "\x1F" / "\u001F")
# 
# @example With default marker and separator
#   NRSER.indent_tag "    hey there!"
#   # => "\x1E    \x1Fhey there!"
# 
# @param [String] text
#   String text to indent tag.
# 
# @param [String] marker
#   Special string to mark the start of tagged lines. If interpolated text
#   lines start with this string you're going to have a bad time.
# 
# @param [String] separator
#   Special string to separate the leading indent from the rest of the line.
# 
# @return [String]
#   Tagged text.
#     
def indent_tag  marker: Ext::String::DEFAULT_INDENT_TAG_MARKER,
                separator: Ext::String::DEFAULT_INDENT_TAG_SEPARATOR
  lines.map { |line|
    indent = if (match = Ext::String::INDENT_RE.match( line ))
      match[ 0 ]
    else
      ''
    end
    
    "#{ marker }#{ indent }#{ separator }#{ line[indent.length..-1] }"
  }.join
end # .indent_tag


# Reverse indent tagging that was done via {NRSER.indent_tag}, indenting
# any untagged lines to the same level as the one above them.
# 
# @param [String] text
#   Tagged text string.
# 
# @param [String] marker
#   Must be the marker used to tag the text.
# 
# @param [String] separator
#   Must be the separator used to tag the text.
# 
# @return [String]
#   Final text with interpolation and indent correction.
# 
def indent_untag  marker: Ext::String::DEFAULT_INDENT_TAG_MARKER,
                  separator: Ext::String::DEFAULT_INDENT_TAG_SEPARATOR
  
  current_indent = ''
  
  lines.map { |line|
    if line.start_with? marker
      current_indent, line = line[marker.length..-1].split( separator, 2 )
    end
    
    current_indent + line
    
  }.join
  
end # #indent_untag


# Indent tag a some text via {NRSER.indent_tag}, call the block with it,
# then pass the result through {NRSER.indent_untag} and return that.
# 
# @param [String] marker
#   Special string to mark the start of tagged lines. If interpolated text
#   lines start with this string you're going to have a bad time.
# 
# @param [String] separator
#   Must be the separator used to tag the text.
# 
# @return [String]
#   Final text with interpolation and indent correction.
# 
def with_indent_tagged  marker: Ext::String::DEFAULT_INDENT_TAG_MARKER,
                        separator: Ext::String::DEFAULT_INDENT_TAG_SEPARATOR,
                        &interpolate_block
  interpolate_block.
    call( n_x.indent_tag marker: marker, separator: separator ).
    n_x.indent_untag( marker: marker, separator: separator )
end # #with_indent_tagged

### @!endgroup Indentation Instance Methods ###


# /Namespace
# ========================================================================

end # module String
end # module Ext
end # module NRSER
