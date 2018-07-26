module NRSER
  # @!group Text Functions
  
  # Split text at whitespace to fit in line length. Lifted from Rails'
  # ActionView.
  # 
  # @see http://api.rubyonrails.org/classes/ActionView/Helpers/TextHelper.html#method-i-word_wrap
  # 
  # @param [String] text
  #   Text to word wrap.
  # 
  # @param [Fixnum] line_width
  #   Line with in number of character to wrap at.
  # 
  # @param [String] break_sequence
  #   String to join lines with.
  # 
  # @return [String]
  #   @todo Document return value.
  # 
  def self.word_wrap text, line_width: 80, break_sequence: "\n"
    text.split("\n").collect! do |line|
      line.length > line_width ? line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1#{break_sequence}").strip : line
    end * break_sequence
  end # .word_wrap
    
end # module NRSER
