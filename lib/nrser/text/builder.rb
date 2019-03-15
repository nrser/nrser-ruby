# encoding: UTF-8
# frozen_string_literal: true
# doctest: true


# Requirements
# =======================================================================

### Project / Package ###

require 'nrser/meta/names/param'

require_relative '../text'
require_relative './list'
require_relative './code'


# Namespace
# =======================================================================

module  NRSER
module  Text


# Definitions
# =======================================================================

# Builder class for constructing texts - accepts a {::Proc} and evaluates it
# in the instance, which provides convenience methods for easily constructing
# elements.
# 
# @example
#   name = :target
#   
#   ::NRSER::Text::Builder.new {[
#     kwd( name ),
#     "argument must be a",
#     list( ::String, ::Symbol, or: ::Integer )
#   ]}.render
#   
#   #=> "`target:` argument must be a {String}, {Symbol} or {Integer}"
# 
class Builder
  
  # Attributes
  # ==========================================================================
  
  # The {Renderer} used to {#render} the {#fragments} into a {::String}.
  # 
  # @return [Renderer]
  #     
  attr_reader :renderer
  
  
  # Sequence of fragments that make up the text.
  # 
  # @return [::Array<::Object>]
  #     
  attr_reader :fragments
  
  
  # Construction
  # ==========================================================================
  
  def initialize renderer: Text.default_renderer, &block
    @renderer = renderer
    @fragments = Array( instance_exec( &block ) )
  end
  
  
  # Instance Methods
  # ==========================================================================
  
  # Shortcut to construct a {List}.
  # 
  # @param [::Array] args
  #   See {List#initialize}.
  # 
  # @return [List]
  # 
  def list *args
    List.new *args
  end
  
  
  def code source
    Code.new source
  end
  
  
  def ruby source
    Code.ruby source
  end
  
  
  # Mark a name 
  # 
  # @param [#to_s] name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def kwd name
    # Turn the `name` into a {::String}, allowing people to pass {::Symbol}s
    # in particular, though of course anything else that makes sense would make
    # sense.
    string = name.to_s
    
    # Add the ':' to the end, unless it's already there, so that 
    # {Meta::Names::Param::Keyword.new} will accept it.
    unless string[ -1 ] == ':'
      string = string + ':'
    end
    
    ruby Meta::Names::Param::Keyword.new( string )
  end # #kwd
  
  
  # Mark a {::String} as being an actual code {::String}, as opposed to being
  # regular prose.
  # 
  # @return [Code]
  # 
  def str string
    Code.ruby string
  end
  
  
  # 
  # @return [Code]
  # 
  def const name
    Code.ruby Meta::Names::Const.new( name )
  end
  
  
  # Render the {#fragments} to a {::String}.
  # 
  # @see Text.join
  # 
  # @return [::String]
  # 
  def render
    renderer.join *fragments 
  end
  
end # class Builder


# /Namespace
# =======================================================================

end # module  Text
end # module  NRSER
