require_relative './nrser/version'
require_relative './nrser/collection'
require_relative './nrser/truthy'

module NRSER
  class << self
    
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

    def erb bnd, str
      require 'erb'
      filter_repeated_blank_lines ERB.new(dedent(str)).result(bnd)
    end # erb

    alias_method :template, :erb

    def format_exception e
      "#{ e.message } (#{ e.class }):\n  #{ e.backtrace.join("\n  ") }"
    end

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

  end # class << self
end

require_relative "./nrser/types"