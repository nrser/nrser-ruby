# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Extending {Callable}
require_relative './callable'

# Describes {Instance}
require_relative './instance'


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  RSpex
module  Described


# Definitions
# =======================================================================

# Abstract base class for all {NRSER::RSpex} description objects.
# 
# Description objects formalize and extend {RSpec}'s explicit subject 
# functionality.
# 
# @abstract
# 
class Params < Base
  
  # Construction
  # ========================================================================
  
  def initialize parent: nil, values: {}
    @positional = {}
    @keyword = {}
    @block = nil
    # TODO  Do I even need this... guess it's dumb to toss data in testing...
    @block_name = nil
    
    values.each &method( :[]= )
  end
  
  # Instance Methods
  # ========================================================================
  
  def []= param_name, value
    t.match param_name,
      Names::PositionalParam, ->( param_name ) {
        @positional[ param_name.var_name ] = value
      },
      
      Names::KeywordParam, ->( param_name ) {
        @keyword[ param_name.var_name ] = value
      },
      
      Names::BlockParam, ->( param_name ) {
        @block_name = param_name
        @block = value
      }
  end
  
end # class Callable


# /Namespace
# =======================================================================

end # module Described
end # module RSpex
end # module NRSER
