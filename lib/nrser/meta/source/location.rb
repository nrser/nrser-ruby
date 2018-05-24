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
  
  include NRSER::Props::Immutable::Vector
  
  
  # Class Methods
  # ============================================================================
  
  # Given an {Enumerable} of {Method} objects, return a {Hash} mapping their
  # {Method#name} to the method's {NRSER::Meta::Source::Location}.
  # 
  # @note
  #   We map the names instead of the {Method} objects themselves because
  #   aliases produce two different {Method} objects that `#==` and `#hash`
  #   the same, preventing them both from being {Hash} keys.
  # 
  # @param [Enumerable<Method>] methods
  #   Methods you want the source locations for.
  # 
  # @param [Boolean] only_valid:
  #   When `true` filter the results to only those that are {#valid?}.
  # 
  # @return [Hash<Symbol, NRSER::Meta::Source::Location>]
  #   Map of method name to their source locations.
  # 
  def self.for_methods methods, only_valid: false
    all = methods.map { |method|
      [ method.name, NRSER::Meta::Source::Location.new( method ) ]
    }.to_h
    
    if only_valid
      all.select { |method, location| location.valid? }
    else
      all
    end
  end # .for_methods
  
  
  # Props
  # ======================================================================
  
  # @!attribute [r] file
  #   The first entry in the source location array, denoting the file path.
  #   
  #   @return [String]
  #     Source file absolute path.
  #   
  #   @return [nil]
  #     No source file available.
  #   
  prop  :file, type: t.abs_path?, default: nil, index: 0
  
  
  # @!attribute [r] line
  #   The second entry in the source location array, denoting the line number.
  #   
  #   @return [Integer]
  #     Positive integer line number in the source {#file}.
  #   
  #   @return [nil]
  #     No line number available.
  #   
  prop  :line, type: t.pos_int?, default: nil, index: 1
  
  
  # Constructor
  # ============================================================================
  
  # Override to allow argument to be `nil` for when {Method#source_location}
  # weirdly returns `nil`.
  # 
  # @param [(#[] & (#each_pair | #each_index)) | nil ] source
  #   Source to construct from:
  #   
  #   1.  `#[] & (#each_pair | #each_index)`
  #       1.  Hash-like that responds to `#each_pair` and contains prop
  #           value sources keyed by their names.
  #           
  #           Supports standard propertied class construction.
  #           
  #           **Examples:**
  #           
  #               {file: '/some/abs/path.rb', line: 88}
  #               {file: '/some/abs/path.rb', line: nil}
  #               {file: nil, line: 88}
  #               {file: nil, line: nil}
  #               {}
  #           
  #       2.  Array-like that responds to `#each_index` and contains prop
  #           values sources indexed by their non-negative integer indexes.
  #           
  #           Supports the output of {Method#source_location}.
  #           
  #           **Examples:**
  #           
  #               ['/some/abs/path.rb', 88]
  #               ['/some/abs/path.rb', nil]
  #               [nil, 88]
  #               [nil, nil]
  #               []
  #           
  #   2.  `nil` - Swapped for `{]` to support times I'm pretty sure I've seen
  #       {Method#source_location} return strait-up `nil`.
  #   
  # 
  def initialize source
    source = source.source_location if source.respond_to? :source_location
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
