require_relative './string/looks_like'

module NRSER
  # @!group String Functions
  
  WHITESPACE_RE = /\A[[:space:]]*\z/
  
  UNICODE_ELLIPSIS = '…'
  
  
  def self.whitespace? string
    string =~ WHITESPACE_RE
  end
  
  
  class << self
    
    # Functions the operate on strings.
    
    # turn a multi-line string into a single line, collapsing whitespace
    # to a single space.
    # 
    # same as ActiveSupport's String.squish, adapted from there.
    def squish str
      str.gsub(/[[:space:]]+/, ' ').strip
    end # squish
    
    alias_method :unblock, :squish
    
    
    def common_prefix strings
      raise ArgumentError.new("argument can't be empty") if strings.empty?
      
      sorted = strings.sort
      
      i = 0
      
      while sorted.first[i] == sorted.last[i] &&
            i < [sorted.first.length, sorted.last.length].min
        i = i + 1
      end
      
      sorted.first[0...i]
    end # common_prefix
    
    
    def filter_repeated_blank_lines str, remove_leading: false
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
    end # filter_repeated_blank_lines
    
    
    def lazy_filter_repeated_blank_lines source, remove_leading: false
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
      
    end # filter_repeated_blank_lines
    

    # Truncates a given +text+ after a given <tt>length</tt> if +text+ is longer than <tt>length</tt>:
    #
    #   'Once upon a time in a world far far away'.truncate(27)
    #   # => "Once upon a time in a wo..."
    #
    # Pass a string or regexp <tt>:separator</tt> to truncate +text+ at a natural break:
    #
    #   'Once upon a time in a world far far away'.truncate(27, separator: ' ')
    #   # => "Once upon a time in a..."
    #
    #   'Once upon a time in a world far far away'.truncate(27, separator: /\s/)
    #   # => "Once upon a time in a..."
    #
    # The last characters will be replaced with the <tt>:omission</tt> string (defaults to "...")
    # for a total length not exceeding <tt>length</tt>:
    #
    #   'And they found that many people were sleeping better.'.truncate(25, omission: '... (continued)')
    #   # => "And they f... (continued)"
    # 
    # adapted from 
    # 
    # <https://github.com/rails/rails/blob/7847a19f476fb9bee287681586d872ea43785e53/activesupport/lib/active_support/core_ext/string/filters.rb#L46>
    # 
    def truncate(str, truncate_at, options = {})
      return str.dup unless str.length > truncate_at

      omission = options[:omission] || '...'
      length_with_room_for_omission = truncate_at - omission.length
      stop = \
        if options[:separator]
          str.rindex(options[:separator], length_with_room_for_omission) || length_with_room_for_omission
        else
          length_with_room_for_omission
        end

      "#{str[0, stop]}#{omission}"
    end
    
    
    # Cut the middle out of a string and stick an ellipsis in there instead.
    # 
    # @param [String] string
    #   Source string.
    # 
    # @param [Fixnum] max
    #   Max length to allow for the output string.
    # 
    # @param [String] omission:
    #   The string to stick in the middle where original contents were 
    #   removed. Defaults to the unicode ellipsis since I'm targeting the CLI
    #   at the moment and it saves precious characters.
    # 
    # @return [String]
    #   String of at most `max` length with the middle chopped out if needed
    #   to do so.
    def ellipsis string, max, omission: UNICODE_ELLIPSIS
      return string unless string.length > max
      
      trim_to = max - omission.length
      
      start = string[0, (trim_to / 2) + (trim_to % 2)]
      finish = string[-( (trim_to / 2) - (trim_to % 2) )..-1]
      
      start + omission + finish
    end 
    
    
    # **EXPERIMENTAL!**
    # 
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
    # @param [String] string
    #   Source string.
    # 
    # @param [Fixnum] max
    #   Max length to allow for the output string. Result will usually be 
    #   *less* than this unless the fallback to {NRSER.ellipsis} kicks in.
    # 
    # @param [String] omission:
    #   The string to stick in the middle where original contents were 
    #   removed. Defaults to the unicode ellipsis since I'm targeting the CLI
    #   at the moment and it saves precious characters.
    # 
    # @param [String] split:
    #   The string to tokenize the `string` parameter by. If you pass a 
    #   {Regexp} here it might work, it might loop out, maybe.
    # 
    # @return [String]
    #   String of at most `max` length with the middle chopped out if needed
    #   to do so.
    # 
    def smart_ellipsis string, max, omission: UNICODE_ELLIPSIS, split: ', '
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
      
    end # #method_name
    
    
    
    # Get the constant identified by a string.
    # 
    # @example
    #   
    #   SomeClass == NRSER.constantize(SomeClass.name)
    # 
    # Lifted from ActiveSupport.
    # 
    # @param [String] camel_cased_word
    #   The constant's camel-cased, double-colon-separated "name",
    #   like "NRSER::Types::Array".
    # 
    # @return [Object]
    # 
    # @raise [NameError]
    #   When the name is not in CamelCase or is not initialized.
    # 
    def constantize(camel_cased_word)
      names = camel_cased_word.split('::')

      # Trigger a built-in NameError exception including the ill-formed constant in the message.
      Object.const_get(camel_cased_word) if names.empty?

      # Remove the first blank element in case of '::ClassName' notation.
      names.shift if names.size > 1 && names.first.empty?

      names.inject(Object) do |constant, name|
        if constant == Object
          constant.const_get(name)
        else
          candidate = constant.const_get(name)
          next candidate if constant.const_defined?(name, false)
          next candidate unless Object.const_defined?(name)

          # Go down the ancestors to check if it is owned directly. The check
          # stops when we reach Object or the end of ancestors tree.
          constant = constant.ancestors.inject do |const, ancestor|
            break const    if ancestor == Object
            break ancestor if ancestor.const_defined?(name, false)
            const
          end

          # owner is in Object, so raise
          constant.const_get(name, false)
        end
      end
    end # constantize
    
    alias_method :to_const, :constantize
    
  end # class << self
end # module NRSER
