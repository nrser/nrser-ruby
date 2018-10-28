# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# =======================================================================

module  NRSER
module  RSpex
module  ExampleGroup
module  Describe


# Definitions
# ========================================================================
  
def dive_x current, *rest, **kwds, &body
  type, data = current
  
  method_name = "describe_#{ type }"
  
  block = if rest.empty?
    body
  else
    -> { dive_x *rest, &body }
  end
  
  begin
    public_send method_name, data, **kwds, &block
  rescue NoMethodError => error
    pp self.methods
    raise error
  end
end


# **EXPERIMENTAL**
# 
# Example group helper for use at the top level of each spec file to
# set a bunch of stuff up and build a helpful description.
# 
# @todo
#   This is totally just a one-off right now... would need to be
#   generalized quite a bit...
#   
#   1.  Extraction of module, class, etc from metadata should be flexible
#       
#   2.  Built description would need to be conditional on what metadata
#       was found.
# 
# @param [String] description
#   A description of the spec file to add to the RSpec description.
# 
# @param [String] spec_path
#   The path to the spec file (just feed it `__FILE__`).
#   
#   Probably possible to extract this somehow without having to provide it?
# 
# @return (see #describe_x)
# 
def describe_spec_file  *description,
                        spec_path:,
                        bind_subject: true,
                        **metadata,
                        &body
  
  if metadata[:description]
    unless description.empty?
      raise NRSER::ArgumentError.new \
        "Can't pass `*description` and `description:` (keyword arg form is",
        "depreciated!)",
        description_splat: description,
        description_kwd: metadata[ :description ]
    end

    description = metadata.delete :description
  end

  chain = []
  
  [
    :source_file,
    :module,
    :class,
    :instance,
    :method,
    :instance_method,
    :called_with,
    :attribute,
  ].each do |type|
    if data = metadata.delete( type )
      chain << [type, data]
    end
  end
  
  describe_x_body = if chain.empty?
    body
  else
    -> { dive_x *chain, bind_subject: bind_subject, &body }
  end

  rel_path = NRSER::RSpex.dot_rel_path( spec_path )
  
  describe_x \
    rel_path,
    *description,
    type: :spec_file,
    metadata: {
      **metadata,
      spec_path: spec_path,
      spec_rel_path: rel_path,
    },
    &describe_x_body
  
end # #describe_spec_file

alias_method :SPEC_FILE, :describe_spec_file


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpex
end # module NRSER
