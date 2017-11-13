# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------
require_relative './lines'


module NRSER
  # @!group Text
  
  
  # Constants
  # =====================================================================
  
  INDENT_RE = /\A[\ \t]*/
  
  
  # Functions
  # =====================================================================
  
  def self.find_indent text
    common_prefix lines( text ).map { |line| line[INDENT_RE] }
  end
  
  
  def self.indented? text
    !( find_indent( text ).empty? )
  end
  
  
  # adapted from active_support 4.2.0
  # 
  # <https://github.com/rails/rails/blob/7847a19f476fb9bee287681586d872ea43785e53/activesupport/lib/active_support/core_ext/string/indent.rb>
  #
  def self.indent str, amount = 2, indent_string = nil, indent_empty_lines = false
    indent_string = indent_string || str[/^[ \t]/] || ' '
    re = indent_empty_lines ? /^/ : /^(?!$)/
    str.gsub(re, indent_string * amount)
  end
  
  
  def self.dedent text, ignore_whitespace_lines: true
    return text if text.empty?
    
    all_lines = text.lines
    
    indent_significant_lines = if ignore_whitespace_lines
      all_lines.reject { |line| whitespace? line }
    else
      all_lines
    end
    
    indent = find_indent indent_significant_lines
    
    return text if indent.empty?
    
    all_lines.map { |line|
      if line.start_with? indent
        line[indent.length..-1]
      elsif line.end_with? "\n"
        "\n"
      else
        ""
      end
    }.join
  end # .dedent
  
  # I like dedent better, but other libs seems to call it deindent
  singleton_class.send :alias_method, :deindent, :dedent
  
end # module NRSER
