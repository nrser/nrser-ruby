# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Stdlib
# ------------------------------------------------------------------------

# Deps
# ------------------------------------------------------------------------

require 'pastel'

# Project / Package
# ------------------------------------------------------------------------

# Using {Object#thru}
require 'nrser/ext/object'

# Submodule
require_relative './format/args'
require_relative './format/description'
require_relative './format/list'
require_relative './format/kwds'


# Namespace
# ============================================================================

module  NRSER
module  Described
module  RSpec


# Definitions
# =======================================================================


# @todo Can I get rid of this..!
# 
def self.format *args
  Format.description *args
end # .format
  

# String formatting utilities.
# 
module Format
  
  def self.short_s value, max = 64
    NRSER.smart_ellipsis value.inspect, max
  end # .short_s
  
  
  # Get the {Pastel} instance to color with. The instance is enabled depending
  # on `::RSpec.configuration.color`.
  # 
  # @return [Pastel]
  # 
  def self.pastel
    @pastel ||= Pastel.new enabled: ::RSpec.configuration.color
  end
  
  
  def self.mean_streak
    @mean_streak ||= NRSER::MeanStreak.new do |ms|
      ms.render_type :emph do |doc, node|
        italic doc.render_children( node )
      end
      
      ms.render_type :strong do |doc, node|
        bold doc.render_children( node )
      end
      
      ms.render_type :code do |doc, node|
        code node.string_content
      end
    end
  end
  
  
  # Italicize a string via "Unicode Math Italic" substitution.
  # 
  # @param [String] string
  # @return [String]
  # 
  def self.unicode_italic string
    NRSER.u_italic string
  end # .italic
  
  
  def self.esc_seq_italic string
    pastel.italic string
  end
  
  
  def self.italic string
    public_send "#{ ::RSpec.configuration.x_style }_#{ __method__ }", string
  end
  
  singleton_class.send :alias_method, :i, :italic
  
  
  def self.esc_seq_bold string
    pastel.bold string
  end
  
  
  # Bold a string via "Unicode Math Bold" substitution.
  # 
  # @param [String] string
  # @return [String]
  # 
  def self.unicode_bold string
    NRSER.u_bold string
  end
  
  
  def self.bold string
    public_send "#{ ::RSpec.configuration.x_style }_#{ __method__ }", string
  end
  
  singleton_class.send :alias_method, :b, :bold
  
  
  def self.rspec_syntax_highlighter
    @rspec_syntax_highlighter ||= \
      ::RSpec::Core::Formatters::SyntaxHighlighter.new ::RSpec.configuration
  end
  
  
  def self.method_name? string
    # Must start with `#` or `.`
    return false unless ['#', '.'].any? { |c| string[0] == c }
    
    name = string[1..-1]
    
    case name
    when  '!', '~', '+', '**', '-', '*', '/', '%', '+', '-', '<<', '>>', '&',
          '|', '^', '<', '<=', '>=', '>', '==', '===', '!=', '=~', '!~', '<=>',
          '[]',
          /\A[a-zA-Z_][a-zA-Z0-9_]*(?:\?|\!|=)?/
      true
    else
      false
    end
  end
  
  
  def self.code string
    if method_name? string
      pastel.bold.blue string
    else
      rspec_syntax_highlighter.highlight string.lines
    end
  end
  
  
  def self.md_code_quote string
    quote = '`' * ((string.scan( /`+/ ).map( &:length ).max || 0) + 1)
    "#{ quote }#{ string }#{ quote }"
  end
  
  
  def self.pathname pn
    if pn.absolute?
      rel = pn.relative_path_from Pathname.getwd
      
      if rel.split( File::SEPARATOR ).first == '..'
        File.join '.', rel
      else
        pn.to_s
      end
    else
      if pn.exist?
        File.join '.', pn
      else
        lib_pn = Pathname.getwd / 'lib' / pn
        
        if lib_pn.exist?
          File.join '.', lib_pn.relative_path_from( Pathname.getwd )
        else
          pn.to_s
        end
      end
    end
  rescue
    pn.inspect
  end
  
end # module Format


# /Namespace
# =======================================================================

end # module RSpec
end # module  Described
end # module NRSER
