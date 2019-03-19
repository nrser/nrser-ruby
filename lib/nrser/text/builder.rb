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

require_relative './tag/paragraph'
require_relative './tag/header'
require_relative './tag/section'


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
#   ::NRSER::Text::Builder.p {[
#     kwd( name ),
#     "argument must be a",
#     list( ::String, ::Symbol, or: ::Integer )
#   ]}.render
#   
#   #=> "`target:` argument must be a {String}, {Symbol} or {Integer}"
# 
class Builder
  
  # Singleton Methods
  # ==========================================================================
  
  # Build just a paragraph.
  # 
  # @param [::Hash<::Symbol, ::Object>] **options
  #   Passed as the keyword arguments to {#initialize}.
  # 
  # @return [Builder]
  #   Constructed instance.
  # 
  def self.paragraph **options, &block
    new( **options ) do
      paragraph *instance_exec( &block )
    end
  end # .paragraph
  
  # Short 'n sweet name (like HTML!)
  singleton_class.send :alias_method, :p, :paragraph
  
  
  # Attributes
  # ==========================================================================
  
  # The {Renderer} used to {#render} the {#fragments} into a {::String}.
  # 
  # @return [Renderer]
  #     
  attr_reader :renderer
  
  
  # Sequence of tags that make up the blocks of text.
  # 
  # @return [::Array<Tag>]
  #     
  attr_reader :blocks
  
  
  # Column to wrap text at, if any. Used to override {Renderer#word_wrap}
  # when calling {Renderer#join}.
  # 
  # @return [false]
  #   No word wrapping.
  # 
  # @return [::Integer]
  #   Positive integer column number to wrap text at.
  #     
  attr_reader :word_wrap
  
  
  # Construction
  # ==========================================================================
  
  def initialize  renderer: Text.default_renderer,
                  word_wrap: nil,
                  &block
    @renderer = renderer
    
    # TODO  Validate?
    @word_wrap = word_wrap
    
    # Where we store the blocks as we build
    @blocks = []
    
    instance_exec &block
    
    # Can't change the blocks now!
    @blocks.freeze
  end
  
  
  # Instance Methods
  # ==========================================================================
  
  def options
    {
      renderer: renderer,
      word_wrap: word_wrap,
    }
  end
  
  
  def append tag
    @blocks << tag
  end
  
  
  def paragraph *fragments
    append Tag::Paragraph.new( *fragments )
  end
  
  alias_method :p, :paragraph
  
  
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
  
  
  # Mark a name ({::String} or similar) as being a Ruby constant name.
  # 
  # @param [#to_s] name
  #   Constant name.
  # 
  # @return [Code]
  # 
  def const name
    Code.ruby Meta::Names::Const.new( name )
  end
  
  
  def header *fragments
    Tag::Header.new *fragments
  end
  
  
  def section *header_fragments, &block
    blocks = self.class.new( **options, &block ).blocks
    
    unless header_fragments.empty?
      blocks = [ header( *header_fragments ), *blocks ]
    end
    
    append Tag::Section.new( *blocks )
  end
  
  
  # Render the {#fragments} to a {::String}.
  # 
  # @see Text.join
  # 
  # @return [::String]
  # 
  def render
    # renderer.join *fragments, word_wrap: word_wrap
    renderer.render_blocks *@blocks, word_wrap: word_wrap
  end
  
end # class Builder


# /Namespace
# =======================================================================

end # module  Text
end # module  NRSER
