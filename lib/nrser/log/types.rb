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
  extend t::Factory
  
  #@!method self.LogLevel **options
  #   A member of {SemanticLogger::LEVELS}.
  #   
  #   @param [Hash] options
  #     Passed to {Type#initialize}.
  #   
  #   @return [Type]
  #   
  def_type        :LogLevel,
    aliases:      [ :level ],
    from_s:       ->( string ) { string.to_sym },
  &->( **options ) do
    t.In SemanticLogger::LEVELS, **options
  end # .LogLevel
  
  
  #@!method self.StdIO **options
  #   An {IO} instance with {Type#from_s} mapping:
  #   
  #       '$stdio'  -> $stdio
  #       '$stderr' -> $stderr
  #       'STDOUT'  -> STDOUT
  #       'STDERR'  -> STDERR
  #   
  #   @param [Hash] options
  #     Passed to {Type#initialize}.
  #   
  #   @return [Type]
  #   
  def_type        :StdIO,
    aliases:      [ :stdio ],
    from_s:       ->( string ) {
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
  &->( **options ) do
    t.IsA IO, **options
  end # .StdIO

end # module Types


# /Namespace
# =======================================================================

end # module Log
end # module NRSER
