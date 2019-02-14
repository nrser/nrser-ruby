# frozen_string_literal: true
# encoding: UTF-8


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require_relative './enumerable/associate'


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Extension methods for {::Binding}
# 
module Binding
  
  # Render `source` {String} with {ERB} against `self` and return results.
  # 
  # @param [String] source
  #   ERB template.
  # 
  # @return [String]
  #   Rendered string.
  # 
  def erb source
    require 'erb'
    
    NRSER.filter_repeated_blank_lines(
      source.n_x.dedent.n_x.with_indent_tagged { |tagged_str|
        ERB.new( tagged_str ).result( self )
      },
      remove_leading: true
    )
  end
  
  alias_method :template, :erb
  
  
  # Get a {Hash} of all local variable names (as {Symbol}) to values.
  # 
  # @return [Hash<Symbol, Object>]
  # 
  def locals
    self.local_variables.n_x.assoc_to { |symbol| local_variable_get symbol }
  end
  
  
  # Get a {Array} of all local variable values.
  # 
  # @return [Array<Object>]
  # 
  def local_values
    self.local_variables.map { |symbol| local_variable_get symbol }
  end
  
end # module Binding


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
