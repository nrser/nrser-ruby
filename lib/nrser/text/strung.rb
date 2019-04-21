# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# =======================================================================

module  NRSER
module  Text


# Definitions
# =======================================================================

# {::String} subclass that hangs on to the object it was created for so that we
# can be smarter about truncation and ellipsis operations.
# 
# @immutable Frozen
# 
class Strung < ::String
  
  # HACK Get this from somewhere else!
  # 
  def self.word_wrap string, line_width: 80, break_sequence: "\n"
    string.split( "\n" ).collect! do |line|
      line.length > line_width ? line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1#{break_sequence}").strip : line
    end * break_sequence
  end # .word_wrap
  
  
  # Attributes
  # ==========================================================================
  
  # Object this {Strung} was created from.
  # 
  # @return [::Object]
  #     
  attr_reader :source
  
  
  # Construction
  # ==========================================================================
  
  # Instantiate a new `Strung`.
  # 
  # @param [::String] string
  #   The string that is passed up to {::String#initialize}, which may be 
  #   mutated in the `&build_block` (if given) before the instance is frozen.
  #   
  #   For this reason it defaults to the empty string: the build block will 
  #   start with that when no argument is provided.
  # 
  def initialize string = '', source:, word_wrap: false, &build_block
    @source = source
    @word_wrap = word_wrap
    
    if word_wrap
      string = self.class.word_wrap( string, line_width: word_wrap )
    end
    
    super( string )
    
    build_block.call( self ) if build_block
    
    freeze
  end # #initialize
  
end # class Strung

# /Namespace
# =======================================================================

end # module  Text
end # module  NRSER
