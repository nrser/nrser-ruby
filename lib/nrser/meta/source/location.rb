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
require 'nrser/props/immutable/self'


# Refinements
# =======================================================================

using NRSER::Types

# Declarations
# =======================================================================

module NRSER::Meta::Source; end


# Definitions
# =======================================================================

# @todo document NRSER::Meta::Source::Location class.
# class NRSER::Meta::Source::Location < NRSER::Props::Immutable::Vector
class NRSER::Meta::Source::Location < Hamster::Vector
  
  # Mixins
  # ============================================================================
  
  include NRSER::Props::Immutable::Self
  
  
  # Constants
  # ======================================================================
  
  
  # Class Methods
  # ======================================================================
  
  
  # Data
  # ======================================================================
  
  prop  :file, type: t.abs_path?, default: nil, key: 0
  prop  :line, type: t.pos_int?, default: nil, key: 1
  
  
  # Constructor
  # ======================================================================
  
  
  # Instance Methods
  # ======================================================================
  
  # @todo Document valid? method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
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
