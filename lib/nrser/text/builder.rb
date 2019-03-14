# encoding: UTF-8
# frozen_string_literal: true
# doctest: true


# Requirements
# =======================================================================

### Project / Package ###

require_relative '../text'
require_relative './list'


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
#   new {[
#     "Argument must be a", list( ::String, ::Symbol, or: ::Integer )
#   ]}.render
#   #=> "Argument must be a String, Symbol or Integer"
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
