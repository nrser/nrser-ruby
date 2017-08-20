module NRSER
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
      sorted = strings.sort.reject {|line| line == "\n"}
      i = 0
      while sorted.first[i] == sorted.last[i] &&
            i < [sorted.first.length, sorted.last.length].min
        i = i + 1
      end
      strings.first[0...i]
    end # common_prefix
    
    
    def dedent str
      return str if str.empty?
      lines = str.lines
      indent = common_prefix(lines).match(/^\s*/)[0]
      return str if indent.empty?
      lines.map {|line|
        line = line[indent.length..line.length] if line.start_with? indent
      }.join
    end # dedent
    
    # I like dedent better, but other libs seems to call it deindent
    alias_method :deindent, :dedent
    
    
    def filter_repeated_blank_lines str
      out = []
      lines = str.lines
      skipping = false
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
    
    
    # adapted from acrive_support 4.2.0
    # 
    # <https://github.com/rails/rails/blob/7847a19f476fb9bee287681586d872ea43785e53/activesupport/lib/active_support/core_ext/string/indent.rb>
    #
    def indent str, amount = 2, indent_string=nil, indent_empty_lines=false
      indent_string = indent_string || str[/^[ \t]/] || ' '
      re = indent_empty_lines ? /^/ : /^(?!$)/
      str.gsub(re, indent_string * amount)
    end
    
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
