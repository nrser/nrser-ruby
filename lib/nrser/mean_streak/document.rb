# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------


# Refinements
# =======================================================================


# Declarations
# =======================================================================


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
        doc: CommonMarker.render_doc( source, options, extensions )
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

  # The lines in {#source} as a {Hamster::Vector} of frozen strings.
  # 
  # @return [Hamster::Vector<String>]
  # 
  def source_lines
    @source_lines = Hamster::Vector.new source.lines.map( &:freeze )
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
        lines[0] = lines[0][(pos[:start_column] - 1)..-1]
      end
      
      # Trim the end off the first line, unless the end column is the last
      # line's length
      unless pos[:end_column] == lines[-1].length
        lines[-1] = lines[-1][0...pos[:end_column]]
      end
      
      lines.join
    end
  end


  def render_node node, output = ''
    
  end
  
end # class NRSER::MeanStreak::Document


# Post-Processing
# =======================================================================
