module NRSER
  
  # Regexp {NRSER.words} uses to split strings. Probably not great but it's
  # what I have for the moment.
  # 
  # @return {Regexp}
  # 
  SPLIT_WORDS_RE = /[\W_\-\/]+/
  
  
  # Split a string into 'words' for word-based matching.
  # 
  # @param [String] string
  #   Input string.
  # 
  # @return [Array<String>]
  #   Array of non-empty words in `string`.
  # 
  def self.words string
    string.split(/[\W_\-\/]+/).reject { |w| w.empty? }
  end # .words
  
end # module NRSER
