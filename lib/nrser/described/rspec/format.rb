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

  # Constants
  # =====================================================================
  
  # Symbol characters for specific example group types.
  # 
  # Sources:
  # 
  # -   https://en.wikipedia.org/wiki/Mathematical_operators_and_symbols_in_Unicode
  # 
  PREFIXES = {
    section: '§',
    group: '•',
    invocation: '𝑓⟮𝑥⟯',
  }
  
  
  def self.short_s value, max = 64
    NRSER.smart_ellipsis value.inspect, max
  end # .short_s
  
  
  def self.pastel
    @pastel ||= Pastel.new
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
    public_send "#{ RSpec.configuration.x_style }_#{ __method__ }", string
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
    public_send "#{ RSpec.configuration.x_style }_#{ __method__ }", string
  end
  
  singleton_class.send :alias_method, :b, :bold
  
  
  def self.rspec_syntax_highlighter
    @rspec_syntax_highlighter ||= \
      RSpec::Core::Formatters::SyntaxHighlighter.new RSpec.configuration
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
  
  
  def self.prepend_type type, description
    return description if type.nil?
    
    prefixes = RSpec.configuration.x_type_prefixes
    
    prefix = pastel.magenta(
      prefixes[type] || i( type.to_s.upcase.gsub('_', ' ') )
    )
    
    "#{ prefix } #{ description }"
  end # .format_type
  
  
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
  
  
  def self.description *parts, type: nil
    parts.
      flat_map { |part|
        if part.respond_to? :to_desc
          desc = part.to_desc
          if desc.empty?
            ''
          else
            md_code_quote desc
          end
        else
          case part
          when Module
            mod = part
            
            name_desc = if mod.anonymous?
              "(anonymous #{ part.class })"
            else
              md_code_quote mod.name
            end
            
            [name_desc, description( mod.source_location )]
            
          when NRSER::Meta::Source::Location
            if part.valid?
              "(#{ Pathname.new( part.file ).n_x.to_dot_rel_s. }:#{ part.line })"
            else
              ''
            end
            
          when String
            part
          
          when Pathname
            pathname part
          
          when NRSER::Message
            [part.symbol, part.args].
              map( &NRSER::RSpec.method( :short_s ) ).join( ', ' )
            
          else
            NRSER::RSpec.short_s part
            
          end
        end
      }.
      join( ' ' ).
      squish.
      n_x.
      thru { |description|
        prepend_type type, mean_streak.render( description )
      }
  end # .description
  
end # module Format


# /Namespace
# =======================================================================

end # module RSpec
end # module NRSER
