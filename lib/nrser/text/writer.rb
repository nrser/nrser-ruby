# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Stdlib ###

### Deps ###

# Using {::String#truncate}
require 'active_support/core_ext/string/filters'

### Project / Package ###


# Refinements
# =======================================================================


# Namespace
# =======================================================================

module  NRSER
module  Text


# Definitions
# =======================================================================

# @todo document Writer class.
# 
class Writer
  
  # Constants
  # ==========================================================================
  
  
  # Singleton Methods
  # ==========================================================================
  
  # Is a {::String} just one line (by `"\n"`)?
  # 
  # Basically, tries to test if {::String#lines} would have length `1`: does 
  # the string have a `"\n"` in it anywhere *except* the last character?
  # 
  # @return [Boolean]
  # 
  def self.single_line? string
    # Should not actually be used for our current use case, since we just bail
    # immediately when asked to write an empty string, but for logical 
    # consistency seems that we should handle empty string, and considering
    # then "single lines" is the reasonable thing to do in my opinion.
    return true if string.length == 0
    
    # Find the index of the first newline character
    first_newline_index = string.index "\n"
    
    # If there is no newline (index is `nil`) *or* the first newline is the 
    # last character then it's a single line for our purposes.
    first_newline_index.nil? || first_newline_index == string.length - 1  
  end
  
  
  # Call a `&block` with each line from a {::String}, with an optimization to
  # avoid copying the string in the case that it is only a single line by
  # simply calling the `&block` once with the `string` itself.
  # 
  # Otherwise, just uses {::String#each_line}.
  # 
  # @param [::String] string
  #   String to test.
  # 
  # @param [λ(::String)⟶void] block
  #   Receives each line (including terminating newline character, if present,
  #   just line {::String#each_line}).
  # 
  def self.each_line string, &block
    if single_line? string
      block.call string
    else
      string.each_line &block
    end
  end
  
  
  def self.word_break_regexp max_length
    /(.{1,#{ max_length }})(?:\s+|$)/
  end
  
  
  # Attributes
  # ==========================================================================
  
  # The destination.
  # 
  # @return [::IO]
  #     
  attr_reader :io
  
  
  # Width (in number of characters) of lines to wrap at.
  # 
  # @return [nil | ::Integer]
  #   Integers must be positive.
  #     
  attr_reader :line_width
  
  
  # How much the writer is currently indenting lines.
  # 
  # @return [::Integer]
  #   Non-negative.
  #     
  attr_reader :indent
  
  
  # What to make indents out of.
  # 
  # @note
  #   Needs to be a single character at the moment, or the math will (likely)
  #   break.
  # 
  # @return [::String]
  #     
  attr_reader :indent_string
  
  
  # A partial line that has not yet been written to the {#io}, waiting on more
  # {#write} calls to provide more text.
  # 
  # @note
  #   Only used when {#line_width} is not `nil`. Reader here for insight and 
  #   debugging ease, you should not need to deal with it.
  # 
  # @return [nil | ::String]
  #     
  attr_reader :line_buffer
  
  
  # Construction
  # ==========================================================================
  
  # Instantiate a new `Writer`.
  def initialize  io:,
                  line_width: nil,
                  indent: 0,
                  indent_string: ' '
    @io = io
    @line_width = line_width
    @indent = indent
    @indent_string = indent_string
    @line_buffer = nil
    @at_line_break = true
  end # #initialize
  
  
  # Instance Methods
  # ==========================================================================
  
  protected
  # ========================================================================
  
    def write_fragment string
      unless line_width
        write_to_io! string
        return
      end
      
      total_width = string.length + effective_indent + line_buffer_length
      
      if total_width <= line_width
        # It's not over a full line, throw it in the buffer
        if line_buffer.nil?
          self.line_buffer = string
        else
          @line_buffer += string
        end
        
        return
      end
      
      # The string - together with whatever may be in the buffer - is over a 
      # line, so we want to break those out and write them, then throw what's
      # left over in the buffer
      
      max_line_length = line_width - effective_indent - line_buffer_length
      string_position = 0
      total_width_remaining = total_width
      
      while string_position < string.length - 1 &&
            total_width_remaining > line_width
        match = self.class.
          word_break_regexp( max_line_length ).
          match( string, string_position )
        
        if match
          unless @line_buffer.nil?
            write_buffer!
            max_line_length = line_width - effective_indent
          end
          
          write_line_to_io! match[ 1 ]
          string_position = match.offset( 0 )[ 1 ]
        else
          if @line_buffer.nil?
            write_line_to_io! string[ string_position..-1 ]
            return
          else
            write_buffer_as_line!
            max_line_length = line_width - effective_indent
          end
        end # if match else
        
        total_width_remaining = string.length - string_position
      end # while
      
      if string_position < string.length - 1
        self.line_buffer = string[ string_position..-1 ]
      end
      
      nil
    end # #write_fragment
    
    
    def write_line line
      unless line_width
        # No line width, which also means no line buffer
        write_line_to_io! line
        return
      end
    
      # Need to account for line width
      
      # Figure out the total we're trying to write, including indent and
      # anything that might be sitting in the line buffer
      
      total_width = effective_indent +
                    line_buffer_length +
                    line.length - 1 # -1 for newline at end
      
      if total_width <= line_width
        # We're good on width, write everything out
        write_buffer! unless line_buffer.nil?
        write_line_to_io! line
        return
      end
      
      # We need to adjust line
      
      max_line_length = line_width - effective_indent - line_buffer_length
      line_position = 0
      
      while line_position < line.length - 1
        match = self.class.
          word_break_regexp( max_line_length ).
          match( line, line_position )
      
        if match
          unless line_buffer.nil?
            write_buffer!
            max_line_length = line_width - effective_indent
          end
          
          write_line_to_io! match[ 1 ]
          line_position = match.offset( 0 )[ 1 ]
        else
          if line_buffer.nil?
            # We didn't find anything for some reason, WTF
            # 
            # TODO  Log this shit in dev?
            # 
            # Fuck it just write it out as a line like it's non-breaking (which
            # is essentially what it is, since we couldn't break it at all)
            write_line_to_io! line[ line_position..-1 ]
            return
          
          else
            # Just clear the buffer out as a line and go back through, since it 
            # doesn't seem like anything can be chopped off the front of `line`
            # to add to it
            write_buffer_as_line!
            max_line_length = line_width - effective_indent
          end
        end # if match else
      end
      
      nil
    end # #write_line
    
    
    def write_indent
      io.write indent_string * indent
    end
    
    
    # What is the *effective* indent - the {#indent} if we are {at_line_break?},
    # and `0` otherwise (for no effective indent).
    # 
    # @return [::Integer]
    #   Zero or greater.
    # 
    def effective_indent
      if at_line_break? then indent else 0 end
    end
    
    
    def indenting?
      at_line_break? && indent > 0
    end
    
    
    def line_buffer= string
      unless string.is_a? ::String
        raise ::TypeError,
          "Expected a {String}, given #{ string.class }: #{ string.inspect }"
      end
      
      if string.empty?
        raise ::ArgumentError, "Given empty string."
      end
      
      unless @line_buffer.nil?
        raise "line buffer not `nil`! Contains #{ @line_buffer.inspect }, " +
              "given #{ string.inspect }"
      end
      
      @line_buffer = string
    end
    
    
    def write_to_io! string
      write_indent if indenting?
      io.write string
      @at_line_break = string[ -1 ] == "\n"
      nil
    end
    
    
    def write_line_to_io! line
      write_indent if indenting?
      io.write line
      io.write( "\n" ) unless line[ -1 ] == "\n"
      @at_line_break = true
      nil
    end
    
    
    def write_buffer!
      write_to_io! @line_buffer
      @line_buffer = nil
      nil
    end
    
    
    def write_buffer_as_line!
      write_line_to_io! @line_buffer
      @line_buffer = nil
      nil
    end
    
  public # end protected ***************************************************
  
  def line_buffer_length
    if line_buffer.nil?
      0
    else
      line_buffer.length
    end
  end
  
  
  def at_line_break?
    @at_line_break
  end
  
  
  def write string
    # Bail early if we received an empty string
    return if string.empty?
    
    self.class.each_line( string ) do |line|
      if line[ -1 ] == "\n"
        write_line line
      else
        write_fragment line
      end
    end
  end # #write
  
  
  def indent! size, &block
    @indent += size
    block.call
  ensure
    @indent -= size
  end
  
  
  def close
    unless line_buffer.nil?
      write_buffer!
    end
  end
  
  
end # class Writer

# /Namespace
# =======================================================================

end # module  Text
end # module  NRSER

