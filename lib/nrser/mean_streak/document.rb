# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------
require 'pastel'

# Project / Package
# -----------------------------------------------------------------------


# Refinements
# =======================================================================

using NRSER


# Declarations
# =======================================================================

class NRSER::MeanStreak; end


# Definitions
# =======================================================================

# @todo document NRSER::MeanStreak::Document class.
class NRSER::MeanStreak::Document
  
  # Constants
  # ======================================================================
  
  
  # Class Methods
  # ======================================================================
  
  # @todo Document from method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [NRSER::MeanStreak::Document]
  #   @todo Document return value.
  # 
  def self.parse  source,
                  mean_streak:,
                  cm_options: :DEFAULT,
                  cm_extensions: []
    new mean_streak: mean_streak,
        source: source,
        doc: CommonMarker.render_doc( source, cm_options, cm_extensions )
  end # .parse
  
  singleton_class.send :alias_method, :from_string, :parse
  singleton_class.send :alias_method, :from_s, :parse
  
  
  
  # Attributes
  # ======================================================================
  
  # The {NRSER::MeanStreak} instance associated with this document, which
  # contains the rendering configuration.
  # 
  # @return [NRSER::MeanStreak]
  #     
  attr_reader :mean_streak


  # The source string.
  # 
  # @return [String]
  #     
  attr_reader :source


  # The root {CommonMarker::Node} (with {CommonMarker::Node#type}=`:document`).
  # 
  # @return [CommonMarker::Node]
  #     
  attr_reader :doc
  
  
  # Constructor
  # ======================================================================
  
  # Instantiate a new `NRSER::MeanStreak::Document`.
  # 
  # @param mean_streak
  #   See {NRSER::MeanStreak::Document#mean_streak}
  # 
  def initialize mean_streak:, source:, doc:
    @mean_streak = mean_streak
    @source = source.dup.freeze
    @doc = doc
  end
  
  
  # Instance Methods
  # ======================================================================
  
  def pastel
    @pastel ||= Pastel.new
  end
  
  
  # The lines in {#source} as a {Hamster::Vector} of frozen strings.
  # 
  # @return [Hamster::Vector<String>]
  # 
  def source_lines
    @source_lines ||= Hamster::List[*source.lines.map( &:freeze )]
  end


  # Get the substring of the source that a node came from (via its
  # `#sourcepos`).
  # 
  # @return [String]
  # 
  def source_for_node node
    pos = node.sourcepos
    
    if pos[:start_line] == pos[:end_line]
      source_lines[pos[:start_line] - 1][
        (pos[:start_column] - 1)...pos[:end_column]
      ]
    else
      lines = source_lines[(pos[:start_line] - 1)...pos[:end_line]]
      
      # Trim the start off the first line, unless the start column is 1
      unless pos[:start_column] == 1
        lines = lines.delete_at( 0 ).add lines[0][(pos[:start_column] - 1)..-1]
      end
      
      # Trim the end off the first line, unless the end column is the last
      # line's length
      unless pos[:end_column] == lines[-1].length
        lines = lines.delete_at( -1 ) << lines[-1][0...pos[:end_column]]
      end
      
      lines.join
    end
  end
  
  
  def source_indexes node
    node.sourcepos.map_values { |k, n| n - 1 }
  end
  
  
  def source_before_first_child node
    node_indexes = source_indexes node
    child_indexes = source_indexes node.first
    
    # Easy case - there is no source before the first child
    if  node_indexes[:start_line] == child_indexes[:start_line] &&
        node_indexes[:start_column] == child_indexes[:start_column]
      return ''
    end
    
    # Ok, hard(er) case now...
    if child_indexes[:start_column] == 0
      # The child starts on the first column of a line, so we need to cut
      # at the end of the previous line
      end_line_index = child_indexes[:start_line] - 1
      end_column_index = -1
    else
      # Child does not start on first column, so use the same line to end and
      # bump the column back one
      end_line_index = child_indexes[:start_line]
      end_column_index = child_indexes[:start_column] - 1
    end
    
    lines = source_lines[node_indexes[:start_line]..end_line_index]
    
    if lines.length == 1
      lines[0][node_indexes[:start_column]..end_column_index]
      
    else
      unless node_indexes[:start_column] == 0
        lines = lines.delete_at( 0 ).add lines[0][node_indexes[:start_column]..-1]
      end
      
      unless end_column_index == -1
        lines = lines.delete_at( -1 ) << lines[-1][0..end_column_index]
      end
      
      lines.join
    end
  end
  
  
  def source_after_last_child node
    node_indexes = source_indexes node
    child_indexes = source_indexes node.each.to_a.last
    
    # Easy case - there is no source after the last child
    if  node_indexes[:end_line] == child_indexes[:end_line] &&
        node_indexes[:end_column] == child_indexes[:end_column]
      return ''
    end
    
    # Ok, hard(er) case now...
    if  child_indexes[:end_column] ==
        source_lines[child_indexes[:end_line]].length - 1
      # The last child ends on the last column of it's last line,
      # so we need to start at the first column of the next line
      start_line_index = child_indexes[:end_line] + 1
      start_column_index = 0
    else
      # Child does not end on last column of line, so use the same line to
      # start and bump the column forward one
      start_line_index = child_indexes[:end_line]
      start_column_index = child_indexes[:end_column] + 1
    end
    
    lines = source_lines[start_line_index..node_indexes[:end_line]]
    
    unless start_column_index == 0
      lines = lines.delete_at( 0 ).add lines[0][start_column_index]
    end
    
    unless node_indexes[:end_column] == lines[-1].length - 1
      lines = lines.delete_at( -1 ) << lines[-1][0..node_indexes[:end_column]]
    end
    
    lines.join
  end
  
  
  def source_offset line:, column:
    offset = column
    if line > 0
      source_lines[0..(line - 1)].each { |l| offset += l.length }
    end
    offset
  end
  
  
  def source_between node_a, node_b
    a_indexes = source_indexes node_a
    b_indexes = source_indexes node_b
    
    a_end_offset = source_offset \
      line: a_indexes[:end_line],
      column: a_indexes[:end_column]
    
    b_start_offset = source_offset \
      line: b_indexes[:start_line],
      column: b_indexes[:start_column]
    
    if a_end_offset + 1 == b_start_offset
      ''
    else
      source[(a_end_offset + 1)..(b_start_offset - 1)]
    end
  end
  
  
  def render_children node
    prev = nil
    parts = []
    node.each do |child|
      unless prev.nil? || prev.type == :code || child.type == :code
        parts << source_between( prev, child )
      end
      
      parts << render_node( child )
      
      prev = child
    end
    
    parts.join
  end
  

  def render_node node #, output = ''
    case node.type
    when :emph
      # pastel.italic node.map( &method( __method__ ) ).join
      pastel.italic render_children( node )
    when :strong
      # pastel.bold node.map( &method( __method__ ) ).join
      pastel.bold render_children( node )
    when :code
      pastel.magenta node.string_content
    else
      if node.first
        # Has children
        source_before_first_child( node ) +
        render_children( node ) +
        source_after_last_child( node )
      else
        # No children! Easy!
        source_for_node node
      end
    end
  end
  
  
  def render
    render_node doc
  end
  
  
  def find_by **attrs
    doc.walk.find_all { |node|
      attrs.all? { |name, value|
        begin
          value === node.send( name )
        rescue
          false
        end
      }
    }
  end
  
  
  def find_type type
    doc.walk.find_all { |node| node.type == type }
  end
  
  
end # class NRSER::MeanStreak::Document
