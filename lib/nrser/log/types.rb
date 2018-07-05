# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Deps
# -----------------------------------------------------------------------

# Need {SemanticLogger::LEVELS}
require 'semantic_logger'


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  Log


# Definitions
# =======================================================================

# Types for logging type things.
# 
# @note
#   This module is **NOT** required when loading {NRSER::Log}, and it **NEVER**
#   should be! It is here for *other* gems and apps that depend on {NRSER}
#   to use.
#   
#   Core logging should have the absolute minimal dependencies, because it's
#   pretty much always going to be loaded and nothing it depends on can use
#   it when loading up.
#   
module Types
  extend NRSER::Types::Factory
  
  def_factory :level do |
    name: 'LogLevel',
    from_s: ->( string ) { string.to_sym },
    **options
  |
    t.in SemanticLogger::LEVELS, from_s: from_s, name: name, **options
  end
  
  
  def_factory :stdio do |
    name: 'StdIO',
    
    from_s: ->( string ) {
      case string
      when '$stdout'
        $stdout
      when '$stderr'
        $stderr
      when 'STDOUT'
        STDOUT
      when 'STDERR'
        STDERR
      end
    },
    
    **options
  |
    t.is_a IO, name: name, from_s: from_s, **options
  end
  
end # module Types


# /Namespace
# =======================================================================

end # module Log
end # module NRSER
