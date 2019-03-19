# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Stdlib ###

### Deps ###

### Project / Package ###


# Refinements
# =======================================================================


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
  def initialize string, source:, word_wrap: false
    @source = source
    @word_wrap = word_wrap
    
    if word_wrap
      string = self.class.word_wrap( string, line_width: word_wrap )
    end
    
    super( string )
    freeze
  end # #initialize
  
end # class Strung

# /Namespace
# =======================================================================

end # module  Text
end # module  NRSER
