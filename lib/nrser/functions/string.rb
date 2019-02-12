# frozen_string_literal: true

module NRSER
  # Constants
  # ==========================================================================
  
  # @!group String Constants
  # --------------------------------------------------------------------------
  
  # Unicode ellipsis character.
  # 
  # @todo Move to `//lib/nrser/char/...`?
  # 
  # @return [String]
  # 
  UNICODE_ELLIPSIS = '…'

  # @!endgroup String Constants # ********************************************

  
  # @!group String Functions
  # ==========================================================================
  
  def self.common_prefix strings
    raise ArgumentError.new("argument can't be empty") if strings.empty?
    
    sorted = strings.sort
    
    i = 0
    
    while sorted.first[i] == sorted.last[i] &&
          i < [sorted.first.length, sorted.last.length].min
      i = i + 1
    end
    
    sorted.first[0...i]
  end # .common_prefix
  
  
  def self.filter_repeated_blank_lines str, remove_leading: false
    out = []
    lines = str.lines
    skipping = remove_leading
    str.lines.each do |line|
      if line =~ /^\s*$/
        unless skipping
          out << line
        end
        skipping = true
      else
        skipping = false
        out << line
      end
    end
    out.join
  end # .filter_repeated_blank_lines
  
  
  def self.lazy_filter_repeated_blank_lines source, remove_leading: false
    skipping = remove_leading
    
    source = source.each_line if source.is_a? String
    
    Enumerator::Lazy.new source do |yielder, line|
      if line =~ /^\s*$/
        unless skipping
          yielder << line
        end
        skipping = true
      else
        skipping = false
        yielder << line
      end
    end
    
  end # .lazy_filter_repeated_blank_lines
  
  
  # Cut the middle out of a sliceable object with length and stick an ellipsis
  # in there instead.
  # 
  # Categorized with {String} functions 'cause that's where it started, and
  # that's probably how it will primarily continue to be used, but tested to
  # work on {Array} and should for other classes that satisfy the same
  # slice and interface.
  # 
  # @param [V & #length & #slice & #<< & #+] source
  #   Source object. In practice, {String} and {Array} work. In theory,
  #   anything that responds to `#length`, `#slice`, `#<<` and `#+` with the
  #   same semantics will work.
  # 
  # @param [Fixnum] max
  #   Max length to allow for the output string.
  # 
  # @param [String] omission
  #   The string to stick in the middle where original contents were
  #   removed. Defaults to the unicode ellipsis since I'm targeting the CLI
  #   at the moment and it saves precious characters.
  # 
  # @return [V]
  #   Object of the same type as `source` of at most `max` length with the
  #   middle chopped out if needed to do so.\*
  #   
  #   \* Really, it has to do with how all the used methods are implemented,
  #   but we hope that conforming classes will return instances of their own
  #   class like {String} and {Array} do.
  # 
  def self.ellipsis source, max, omission: UNICODE_ELLIPSIS
    return source unless source.length > max
    
    trim_to = max - ( String === source ? omission.length : 1 )
    middle = trim_to / 2
    remainder = trim_to % 2
    
    start = source.slice( 0, middle + remainder )
    start << omission
    
    finish = source.slice( -( middle - remainder )..-1 )
    
    start + finish
  end # .ellipsis
  
  
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
  def self.smart_ellipsis string, max, omission: UNICODE_ELLIPSIS, split: ', '
    return string unless string.length > max
    
    unless string.include? split
      return ellipsis string, max, omission: omission
    end
    
    tokens = string.split split
    
    char_budget = max - omission.length
    start = tokens[0] + split
    finish = tokens[tokens.length - 1]
    
    if start.length + finish.length > char_budget
      return ellipsis string, max, omission: omission
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
  
  # @!endgroup String Functions
  
end # module NRSER
