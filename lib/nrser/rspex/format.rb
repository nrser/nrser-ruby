require 'pastel'

using NRSER

# Definitions
# =======================================================================

# String formatting utilities.
# 
module NRSER::RSpex::Format

  
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
  
  
  def self.transpose_A_z string, lower_a:, upper_a:
    string
      .gsub( /[A-Z]/ ) { |char|
        [upper_a.ord + (char.ord - 'A'.ord)].pack 'U*'
      }
      .gsub( /[a-z]/ ) { |char|
        [lower_a.ord + (char.ord - 'a'.ord)].pack 'U*'
      }
  end
  
  
  # Italicize a string
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.unicode_italic string
    transpose_A_z string, lower_a: '𝑎', upper_a: '𝐴'
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
  
  
  def self.bold string
    # FIXME   Should switch on config once {.unicode_bold} is written
    esc_seq_bold string
  end
  
  singleton_class.send :alias_method, :b, :bold
  
  
  def self.code string
    pastel.yellow string
  end
  
  
  def self.md_code_quote string
    quote = '`' * ((string.scan( /`+/ ).map( &:length ).max || 0) + 1)
    "#{ quote }#{ string }#{ quote }"
  end
  
  
  # @todo Document format_type method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.prepend_type type, description
    return description if type.nil?
    
    prefixes = RSpec.configuration.x_type_prefixes
    
    prefix = prefixes[type] ||
              pastel.magenta( i( type.to_s.upcase.gsub('_', ' ') ) )
    
    "#{ prefix } #{ description }"
  end # .format_type
  
  
  # @todo Document format method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [String]
  # 
  def self.description *parts, type: nil
    parts.
      map { |part|
        if part.respond_to? :to_desc
          md_code_quote part.to_desc
        elsif part.is_a? String
          part
        else
          short_s part
        end
      }.
      join( ' ' ).
      squish.
      thru { |description|
        mean_streak.render prepend_type( type, description )
      }
  end # .description
  
end # module NRSER::RSpex::Format


# Post-Processing
# =======================================================================
