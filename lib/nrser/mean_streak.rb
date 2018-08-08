# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------
require 'commonmarker'

# Project / Package
# -----------------------------------------------------------------------
require_relative './mean_streak/document'


# Refinements
# =======================================================================


# Declarations
# =======================================================================


# Definitions
# =======================================================================


# Tag up terminals with color and style. Uses {CommonMarker} for the parsing
# (Markdown / CommonMark / GFM syntax).
# 
# {NRSER::MeanStreak} instances hold configuration and provide functionality
# through instance methods, making it easy to use multiple configurations or
# subclass {NRSER::MeanStreak} to further customize functionality.
# 
# An instance with default configuration is available via the {.default}
# class method, and additional class methods are provided that proxy to the
# default's instance methods, providing convenient use of the default config.
# 
class NRSER::MeanStreak
  
  # Class Methods
  # ======================================================================
  
  # Get the default instance, which has the default configuration and is
  # used by the class methods.
  # 
  # @return [NRSER::MeanStreak]
  # 
  def self.default
    # TODO cache?
    new
  end # .default
  
  
  # Public: Parses a Markdown string into a `document` node.
  #
  # string - {String} to be parsed
  # option - A {Symbol} or {Array of Symbol}s indicating the parse options
  # extensions - An {Array of Symbol}s indicating the extensions to use
  #
  # @return [CommonMarker::Node]
  #   The `document` node.
  # 
  def self.parse source, options = :DEFAULT, extensions = []
    default.parse source, cm_options: options, cm_extensions: extensions
  end
  
  
  # TODO document `type_renderers` attribute.
  # 
  # @return [Hash<Symbol, Proc>]
  #     
  attr_reader :type_renderers
  
  
  
  def initialize &block
    @type_renderers = {}
    block.call( self ) if block
  end
  
  
  # Instance Methods
  # ============================================================================
  
  def render_type type, &renderer
    @type_renderers[type] = renderer
  end
  
  
  def parse source, **options
    NRSER::MeanStreak::Document.parse \
      source,
      **options,
      mean_streak: self
  end # #parse
  
  
  # Render a {NRSER::MeanStreak::Document} or a source string.
  # 
  # @param [NRSER::MeanStreak::Document | String] doc_or_source
  #   Document or source to render.
  # 
  # @return [String]
  #   Rendered string.
  # 
  def render doc_or_source
    case doc_or_source
    when NRSER::MeanStreak::Document
      doc_or_source.render
      
    when ''
      # Short-circuit for empty strings because CommonMark's document
      # node for empty strings returns a weird `#sourcepos` that ends before it
      # begins (start: line 1, column 1; end: line 0, column 0).
      # 
      # Going to protect against line 0 / column 0 in
      # {NRSER::MeanStreak::Document#source_byte_indexes} too but since the
      # empty strings just renders the empty string we can just return that
      # here.
      # 
      ''
    
    else
      parse( doc_or_source ).render
    end
  end
  
  
end # class NRSER::ShellDown
