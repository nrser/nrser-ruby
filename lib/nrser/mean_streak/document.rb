# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Deps
# -----------------------------------------------------------------------
require 'pastel'


# Refinements
# =======================================================================

using NRSER
using NRSER::Types


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
  
  
  def source_byte_indexes node
    pos = node.sourcepos
    
    indexes = {
      first_byte: {
        line: pos[:start_line] - 1,
        column: pos[:start_column] - 1,
      },
      last_byte: {
        line: pos[:end_line] - 1,
        column: pos[:end_column] - 1,
      },
    }
    
    indexes.each do |key, byte_index_pos|
      byte_index_pos[:index] = source_byte_index **byte_index_pos
    end
    
    indexes
  end
  
  
  def source_byte_index line:, column:
    # source_lines[0...line].map( &:bytesize ).reduce( column, :+ )
    byte_index = column
    if line > 0
      source_lines[0..(line - 1)].each { |_| byte_index += _.bytesize }
    end
    byte_index
  end
  
  
  def source_byteslice **kwds
    t.and(
      # All the values must be `nil` or non-negative integer
      t.hash_(keys: t.sym, values: t.non_neg_int?),
      # Exactly one of `start_on` and `start_after` must be `nil`
      t.xor(t.shape(start_on: nil), t.shape(start_after: nil)),
      # Exactly one of `end_on` and `end_before` must be `nil`
      t.xor(t.shape(end_on: nil), t.shape(end_before: nil))
    ).check kwds
    
    # The first byte we're gonna slice is either the `start_on` keyword
    # provided or the `start_after` bumped forward by 1 (which we can do
    # because it must point to the last *byte* before the slice, *not the
    # character*, so +1 gets us to the first slice byte)
    start_on = kwds[:start_on] || (kwds[:start_after] + 1)
    
    # In the same way, we can figure out the last byte after the slice
    end_before = kwds[:end_before] || (kwds[:end_on] + 1)
    
    # Sanity check
    if start_on > end_before
      # We done fucked up, which is not that unusual for me with this shit
      raise "Shit... start_on: #{ start_on }, end_before: #{ end_before }"
    end
    
    # Take the slice... the `...` range seems kinda easier 'cause the resulting
    # byte size is the difference `next_byte - end_before`
    source.byteslice start_on...end_before
  end
  
  
  # Get the substring of the source that a node came from (via its
  # `#sourcepos`).
  # 
  # @return [String]
  # 
  def source_for_node node
    indexes = source_byte_indexes node
    
    # This one is *really* easy now!
    source_byteslice(
      # Start on the first byte
      start_on: indexes[:first_byte][:index],
      # End on the last
      end_on: indexes[:last_byte][:index]
    )
  end
  
  
  def source_between start_node, end_node
    # Ok, all we do is take a byte slice based on their byte indexes
    source_byteslice(
      # The index of the start node's last type is the byte just *before*
      # the slice starts
      start_after: source_byte_indexes( start_node )[:last_byte][:index],
      # The index of the end node's first byte is the byte just *after* the
      # slice ends
      end_before: source_byte_indexes( end_node )[:first_byte][:index]
    )
  end
  
  
  def source_before_first_child node
    slice = source_byteslice(
      start_on: source_byte_indexes( node )[:first_byte][:index],
      end_before: source_byte_indexes( node.first )[:first_byte][:index],
    )
    
    # See comments in {#render_children}
    if  mean_streak.type_renderers[:code] &&
        node.first.type == :code &&
        slice.start_with?( '`' )
      slice = slice.sub /\A`+/, ''
    end
    
    slice
  end
  
  
  def source_after_last_child node
    last_child = node.each.to_a.last
    
    slice = source_byteslice(
      start_after: source_byte_indexes( last_child )[:last_byte][:index],
      end_on: source_byte_indexes( node )[:last_byte][:index]
    )
    
    # See comments in {#render_children}
    if  mean_streak.type_renderers[:code] &&
        last_child.type == :code &&
        slice.end_with?( '`' )
      slice = slice.sub /`+\z/, ''
    end
    
    slice
  end
  
  
  def render_children node
    prev = nil
    parts = []
    node.each do |child|
      unless prev.nil?
        between = source_between( prev, child )
        
        # We may need to modify the source strings *surrounding* specific
        # nodes...
        # 
        # `:code` is an example thus far: it stores the code string in
        # `#string_content` so - unlike `:emph` and `:strong` where the
        # delimiters end up in the "before first child" and "after last child"
        # *inside* the node's source slice - in `:code` they end up *outside*,
        # in the source between it and the previous and next sibling nodes.
        # 
        # 
        # 
        if mean_streak.type_renderers[:code]
          # There is a renderer for the `:code` type, so assume that it will
          # take are of any surrounding characters for `:code` strings and
          # chomp off the starting and ending backticks
          if prev.type == :code
            # Previous node is `:code`, chomp off any leading backtick
            # between = between[1..-1] if between.start_with?( '`' )
            between = between.sub /\A`+/, ''
          elsif child.type == :code
            # Current node is `:code`, chomp off any leading backtick
            between = between.sub /`+\z/, ''
          end
        end
        
        parts << between
      end
      
      parts << render_node( child )
      
      prev = child
    end
    
    parts.join
  end
  
  
  def render_node_2 prev_node, source_before, node, source_after, next_node
    
  end
  

  def render_node node
    if mean_streak.type_renderers[node.type]
      mean_streak.type_renderers[node.type].call self, node
    # case node.type
    # when :emph
    #   # pastel.italic node.map( &method( __method__ ) ).join
    #   pastel.italic render_children( node )
    # when :strong
    #   # pastel.bold node.map( &method( __method__ ) ).join
    #   pastel.bold render_children( node )
    # when :code
    #   pastel.magenta node.string_content
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
