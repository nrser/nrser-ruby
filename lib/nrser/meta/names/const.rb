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

# Extends {Name}
require_relative './name'


# Refinements
# =======================================================================

require 'nrser/refinements/regexps'
using NRSER::Regexps


# Namespace
# =======================================================================

module  NRSER
module  Meta
module  Names


# Definitions
# =======================================================================

# Name of a constant, which may point to a {::Class}, {::Module} or just any
# old value.
# 
# @example
#   name = NRSER::Meta::Names::Module.new 'NRSER::Ext::Regexp'
#   #=> "NRSER::Ext::Regexp"
#   
#   name.class
#   #=> NRSER::Meta::Names::Module
#   
#   name.const_names
#   #=> ["NRSER", "Ext", "Regexp"]
#   
#   name.top_level?
#   #=> false
# 
# @example Top-level name
#   name = NRSER::Meta::Names::Module.new '::NRSER::Ext::Regexp'
#   #=> "::NRSER::Ext::Regexp"
#   
#   name.const_names
#   #=> ["NRSER", "Ext", "Regexp"]
#   
#   name.top_level?
#   #=> true
# 
class Const < Name
  
  # An individual piece of a {Const} name (parts that appear between "::").
  # 
  class Segment < Name
    pattern /\A[A-Z][A-Za-z_]*\z/
  end

  
  pattern \
    re.maybe( '::' ),
    Segment,
    re.any( re.join( '::', Segment) )
  
  
  # The {Segment} instances that make up the name.
  # 
  # @return [Array<NRSER::Meta::Names::Const::Segment>]
  #     
  attr_reader :segments
  
  
  # Does it start with '::'?
  # 
  # @return [Boolean]
  #     
  attr_reader :is_absolute
  
  
  def initialize string
    strings = string.split '::'
    
    @absolute = if strings.first.empty?
      strings.shift
      true
    else
      false
    end
    
    @segments = strings.map &Segment.method( :new )
    
    super( string )
  end # #initialize
  
  
  # Predicate method for {#is_absolute} (does it start with '::'?).
  # 
  # @return [Boolean]
  # 
  def absolute?
    is_absolute
  end
  
  # Original name for {#absolute?}
  alias_method :is_top_level?, :absolute?
  
end # class Const


# /Namespace
# =======================================================================

end # module Names
end # module Meta
end # module NRSER
