require 'pastel'

using NRSER

# Definitions
# =======================================================================

# String formatting utilities.
# 
module NRSER::RSpex::Format

  
  PASTEL = Pastel.new
  
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
    PASTEL.italic string
  end
  
  
  def self.italic string
    public_send "#{ RSpec.configuration.x_style }_#{ __method__ }", string
  end
  
  singleton_class.send :alias_method, :i, :italic
  
  
  def self.fix_esc_seq commonmark
    commonmark.gsub( "\e\\[", "\e[" )
  end
  
  
  # @todo Document render_commonmark method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.render_shelldown *render_doc_args
    doc = CommonMarker.render_doc *render_doc_args
    
    transformed = transform_node( doc ).only!
    commonmark = transformed.to_commonmark
    ansi = fix_esc_seq commonmark
    ansi
  end # .render_commonmark
  
  
  def self.text_node string_content
    CommonMarker::Node.new( :text ).tap { |node|
      node.string_content = string_content
    }
  end
  
  
  def self.pastel_node name
    text_node PASTEL.lookup( name )
  end
  
  
  def self.transform_node node
    case node.type
    when :emph
      [
        pastel_node( :italic ),
        node.map { |child| transform_node child },
        pastel_node( :clear ),
      ].flatten
    when :strong
      [
        pastel_node( :bold ),
        node.map { |child| transform_node child},
        pastel_node( :clear ),
      ].flatten
    when :text
      [node]
    when :code
      [
        pastel_node( :magenta ),
        text_node( node.string_content ),
        pastel_node( :clear ),
      ]
    else
      new_node = CommonMarker::Node.new node.type
      
      # new_node.string_content = node.string_content
      
      node.
        each { |child|
          transform_node( child ).each { |new_child|
            new_node.append_child new_child
          }
        }
      
      [new_node]
    end
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
              PASTEL.magenta( i( type.to_s.upcase.gsub('_', ' ') ) )
    
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
          part.to_desc
        elsif part.is_a? String
          part
        else
          short_s part
        end
      }.
      join( ' ' ).
      squish.
      thru { |description|
        render_shelldown prepend_type( type, description )
      }
  end # .description
  
end # module NRSER::RSpex::Format


# Post-Processing
# =======================================================================
