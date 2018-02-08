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
  
  
  # Instance Methods
  # ============================================================================
  
  
  # @todo Document parse method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def parse source, **options
    NRSER::MeanStreak::Document.parse \
      source,
      **options,
      mean_streak: self
  end # #parse
  
  
end # class NRSER::ShellDown
