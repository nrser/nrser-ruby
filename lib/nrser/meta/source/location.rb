# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/props'
require 'nrser/props/immutable/vector'


# Refinements
# =======================================================================

using NRSER::Types

# Declarations
# =======================================================================

module NRSER::Meta::Source; end


# Definitions
# =======================================================================

# @todo document NRSER::Meta::Source::Location class.
# 
class NRSER::Meta::Source::Location < Hamster::Vector
  
  # Mixins
  # ============================================================================
  
  # include NRSER::Props::Immutable::Self
  
  
  
  include NRSER::Props::Immutable::Vector
  
  
  
  # include NRSER::Props
  # 
  # props.immutable = true
  # props.storage = :[]
  
  
  # Constants
  # ======================================================================
  
  
  # Class Methods
  # ======================================================================
  
  
  # Props
  # ======================================================================
  
  prop  :file, type: t.abs_path?, default: nil, key: 0
  prop  :line, type: t.pos_int?, default: nil, key: 1
  
  
  
  # Constructor
  # ============================================================================
  
  def initialize source
    source = {} if source.nil?
    super source
  end
  
  
  # Instance Methods
  # ======================================================================
  
  # Do we have a file and a line?
  # 
  # Sometimes `#source_location` gives back `nil` values or just `nil`
  # (in which case we set both {#file} and {#line} to `nil`). I think this
  # has to do with C extensions and other weirdness.
  # 
  # Anyways, this helps you handle it.
  # 
  # @return [Boolean]
  # 
  def valid?
    !( file.nil? && line.nil? )
  end # #valid?
  
  
  # @return [String]
  #   a short string describing the instance.
  # 
  def to_s
    "#{ file || '???' }:#{ line || '???' }"
  end # #to_s
  
  
end # class NRSER::Meta::Source::Location
