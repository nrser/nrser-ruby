# frozen_string_literal: true
# encoding: UTF-8

# Requirements
# ========================================================================

# Stdlib
# ------------------------------------------------------------------------

require 'pathname'

# Project / Package
# ------------------------------------------------------------------------

# Submodules
require_relative './pathname/subpath'


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# ========================================================================

# Extensions to the stdlib's {::Pathname} class.
# 
# @note
#   This module must be *prepended*, **not included** in order for {#sub} to
#   work (it uses `super`).
#   
#   Decent explination here:
#   
#   https://medium.com/@leo_hetsch/ruby-modules-include-vs-prepend-vs-extend-f09837a5b073
# 
module Pathname

  # Class Methods
  # ========================================================================

  # @raise [RuntimeError]
  #   When called to prevent this module being included (it needs to 
  #   *prepended* for {#sub} to work).
  #    
  def self.included base
    raise RuntimeError,
          "{NRSER::Ext::Pathname} needs to be prepended, not included" +
          "in order for `#sub` to work!"
  end
  

  def self.relative? path
    path = ::Pathname.new( path ) unless path.is_a?( Pathname )

    path.relative?
  end


  def self.absolute? path
    !relative?( path )
  end


  # Instance Methods
  # ========================================================================
  
  # Override to accept {::Pathname} instances.
  # 
  # @param [String] prefixes
  #   The prefixes to see if the {::Pathname} starts with.
  # 
  # @return [Boolean]
  #   `true` if the {::Pathname} starts with any of the prefixes.
  # 
  def start_with? *prefixes
    to_s.start_with? *prefixes.map { |prefix|
      if Pathname === prefix
        prefix.to_s
      else
        prefix
      end
    }
  end

  
  # Our override of `#sub` to support {::Pathname} instances as patterns.
  # 
  # Just calls `#to_s` on `pattern` if it's a {::Pathname} before passing up
  # to the super method.
  # 
  # @param [::String | ::Regexp | ::Pathname] pattern
  #   Thing to replace.
  # 
  # @param args
  #   See Ruby core's [String#sub][], which [Pathname#sub][] calls between 
  #   stringifying and re-wrapping in a {::Pathname} (core's [String#sub][] is 
  #   overloaded).
  #   
  #   [String#sub]: https://ruby-doc.org/core/String.html#method-i-sub
  #   [Pathname#sub]: https://ruby-doc.org/stdlib/libdoc/pathname/rdoc/Pathname.html#method-i-sub
  # 
  # @param [::Proc] block
  #   See [String#sub][].
  # 
  # @return [::Pathname]
  #   A brand new Pathname boys and girls!
  # 
  def sub pattern, *args, &block
    case pattern
    when ::Pathname
      super pattern.to_s, *args, &block
    else
      super pattern, *args, &block
    end
  end


  # Just returns `self`. Implemented to match the {String#to_pn} API so it
  # can be called on an argument that may be either one.
  # 
  # @return [::Pathname]
  # 
  def to_pn
    self
  end
  
  
  # See {NRSER.find_up}.
  # 
  def find_up rel_path, **kwds
    NRSER.find_up rel_path, **kwds, from: self
  end # #find_root
  
  
  # See {NRSER.find_up!}.
  # 
  def find_up! rel_path, **kwds
    NRSER.find_up! rel_path, **kwds, from: self
  end # #find_root
  
  
  # Shortcut to convert into a relative pathname, by default from the working
  # directory, with option to `./` prefix.
  # 
  # @param [::Pathname] base_dir
  #   Directory you want the result to be relative to.
  # 
  # @param [Boolean] dot_slash
  #   When `true` will prepend `./` to the resulting path, unless it already
  #   starts with `../`.
  # 
  # @return [::Pathname]
  # 
  def to_rel base_dir: ::Pathname.getwd, dot_slash: false
    rel = relative_path_from base_dir
    
    if dot_slash && !rel.start_with?( /\.\.?\// )
      ::Pathname.new File.join( '.', rel )
    else
      rel
    end
  end
  
  
  # Shortcut to call {#to_rel} with `dot_slash=true`.
  # 
  # @param base_dir: (see .to_rel)
  # @return (see .to_rel)
  # 
  def to_dot_rel **kwds
    to_rel **kwds, dot_slash: true
  end # #to_dot_rel
  
  
  # Just a quick cut for `.to_rel.to_s`, since I seem to use that sort of form
  # a lot.
  # 
  # @param (see #to_rel)
  # 
  # @return [String]
  # 
  def to_rel_s **kwds
    to_rel( **kwds ).to_s
  end
  
  
  # Shortcut to call {#to_rel_s} with `dot_slash=true`.
  # 
  # @param base_dir: (see .to_rel_s)
  # @return (see .to_rel_s)
  # 
  def to_dot_rel_s **kwds
    to_rel_s( **kwds, dot_slash: true ).to_s
  end


  # The "closest" directory - which is `self` if the instance is a
  # {#directory?}, otherwise it's {#dirname}.
  # 
  # @return [::Pathname]
  # 
  def closest_dir
    directory? ? self : dirname
  end
  
end # module Pathname


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
