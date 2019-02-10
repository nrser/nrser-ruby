# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ============================================================================

### Stdlib ###

### Deps ###

### Project / Package ###

require 'nrser/ext/pathname'


# Namespace
# =======================================================================

module  NRSER
module  RSpec
module  ExampleGroup
module  Describe


# Definitions
# ========================================================================

# Create an example group corresponding to a source file.
# 
# @note
#   I tried to wack this as part of the `v0.4` refactor, but it's used in 
#   the {NRSER::Types} specs, where it actually proves rather useful: because
#   the type factory methods are defined by providing the method body as a 
#   block to {NRSER::Types::Factory#def_type} their source locations are all in
#   `//lib/nrser/types/factory.rb` instead of the file the `def_type` calls were
#   made.
# 
# @see #describe_x
#
# @param [String | Pathname] path
#   File path.
# 
# @param *description (see #describe_x)
# 
# @param [Hash<Symbol, Object>] metadata
#   RSpec metadata to set for the example group.
#   
#   See the `metadata` keyword argument to {#describe_x}.
# 
# @param &body (see #describe_x)
# 
# @return (see #describe_x)
# 
def describe_source_file path, *description, **metadata, &body
  path = path.to_pn

  abs_path = if path.absolute?
    path
  elsif path.file?
    path.expand_path
  elsif ::Pathname.getwd.join( 'lib', path ).file?
    ::Pathname.getwd.join( 'lib', path ).expand_path
  else
    logger.warn "Unable to resolve relative source file path",
      path: path.to_s
    
    nil
  end

  rel_path = abs_path && abs_path.n_x.to_dot_rel_s
  
  describe_x \
    path,
    *description,
    type: :source_file,
    metadata: {
      source_file_path: path,
      source_file_abs_path: abs_path,
      source_file_rel_path: rel_path,
      **metadata,
    },
    &body
end

alias_method :SOURCE_FILE, :describe_source_file

# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpec
end # module NRSER
