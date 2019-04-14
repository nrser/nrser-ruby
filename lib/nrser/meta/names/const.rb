# encoding: UTF-8
# frozen_string_literal: true
# doctest: true

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
#   name = ::NRSER::Meta::Names::Const.new 'NRSER::Ext::Regexp'
#   #=> "NRSER::Ext::Regexp"
#   
#   name.class
#   #=> NRSER::Meta::Names::Const
#   
#   name.segments
#   #=> ["NRSER", "Ext", "Regexp"]
#   
#   name.segments.all? { |segment|
#     segment.is_a? NRSER::Meta::Names::Const::Segment
#   }
#   #=> true
#   
#   name.absolute?
#   #=> false
# 
# @example Top-level name
#   name = ::NRSER::Meta::Names::Const.new '::NRSER::Ext::Regexp'
#   #=> "::NRSER::Ext::Regexp"
#   
#   name.segments
#   #=> ["NRSER", "Ext", "Regexp"]
#   
#   name.absolute?
#   #=> true
# 
class Const < Name
  
  # An individual piece of a {Const} name (parts that appear between "::").
  # 
  class Segment < Name
    pattern /\A[A-Z][A-Za-z0-9_]*\z/
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
  
  
  def initialize string
    strings = string.split '::'
    
    @absolute = if strings.first.empty?
      strings.shift
      true
    else
      false
    end
    
    @segments = strings.map( &Segment.method( :new ) ).freeze
    
    super( string )
  end # #initialize
  
  
  # Does it start with '::'?.
  # 
  # @return [Boolean]
  # 
  def absolute?
    @absolute
  end
  
end # class Const


# /Namespace
# =======================================================================

end # module Names
end # module Meta
end # module NRSER
