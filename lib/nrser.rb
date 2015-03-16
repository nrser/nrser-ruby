require "nrser/version"

module NRSER
  module KernelRefinements
    def tpl *args
      NRSER::template *args
    end
  end

  refine Object do
    include KernelRefinements

    def pipe
      yield self
    end

  end

  refine String do
    def unblock
      NRSER.unblock self
    end

    def dedent
      NRSER.dedent self
    end

    def indent
      NRSER.indent self
    end
  end # refine String

  refine Exception do
    def format
      NRSER.format_exception self
    end
  end

  using NRSER

  def self.unblock str
    parts = str.split(/\n\s+/)
    if m = parts[0].match(/^\s+/)
      parts[0] = parts[0][m.end(0)..-1]
    end
    if m = parts[-1].match(/\s+$/)
      parts[-1] = parts[-1][0..m.begin(0)]
    end
    parts.join ' '
  end # unblock

  def self.common_prefix strings
    raise ArgumentError.new("argument can't be empty") if strings.empty?
    sorted = strings.sort.reject {|line| line == "\n"}
    i = 0
    while sorted.first[i] == sorted.last[i] &&
          i < [sorted.first.length, sorted.last.length].min
      i = i + 1
    end
    strings.first[0...i]
  end # common_prefix

  def self.dedent str
    return str if str.empty?
    lines = str.lines
    indent = common_prefix(lines).match(/^\s*/)[0]
    return str if indent.empty?
    lines.map {|line|
      line = line[indent.length..line.length] if line.start_with? indent
    }.join
  end # dedent

  def self.filter_repeated_blank_lines str
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

  def self.template bnd, str
    require 'erb'
    filter_repeated_blank_lines ERB.new(dedent(str)).result(bnd)
  end # template

  def self.format_exception e
    "#{ e.message } (#{ e.class }):\n  #{ e.backtrace.join("\n  ") }"
  end

  # adapted from acrive_support 4.2.0
  # 
  # <https://github.com/rails/rails/blob/7847a19f476fb9bee287681586d872ea43785e53/activesupport/lib/active_support/core_ext/string/indent.rb>
  #
  def self.indent str, amount = 2, indent_string=nil, indent_empty_lines=false
    indent_string = indent_string || str[/^[ \t]/] || ' '
    re = indent_empty_lines ? /^/ : /^(?!$)/
    str.gsub(re, indent_string * amount)
  end

end
