# encoding: UTF-8
# frozen_string_literal: true
# doctest: true


# Requirements
# =======================================================================

### Project / Package ###

require 'nrser/meta/names/param'

require_relative '../text'

require_relative './tag/list'
require_relative './tag/code'
require_relative './tag/paragraph'
require_relative './tag/header'
require_relative './tag/section'
require_relative './tag/values'


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
    
    # Where we store the top-level blocks as we build
    @blocks = []
    
    @stack = [ [ :top, @blocks ] ]
    
    instance_exec &block
    
    # Can't change the blocks now!
    @blocks.freeze
  end
  
  
  # Instance Methods
  # ==========================================================================  
  
  # Render the {#blocks} to a {::String}.
  # 
  # @see Text.join
  # 
  # @return [::String]
  # 
  def render
    # renderer.join *fragments, word_wrap: word_wrap
    renderer.render_blocks blocks, word_wrap: word_wrap
  end
  
  
  protected
  # ========================================================================
    
    # Append a {Tag} to the {#blocks}.
    # 
    # @param [Tag] tag
    # @return [self]
    # 
    def append tag
      @stack.last[ 1 ] << tag
      self
    end
    
    
    def push tag_class, **new_tag_kwds, &block
      @stack << [ tag_class, [] ]
      block.call
    ensure
      popped_tag_class, popped_blocks = @stack.pop
      
      if new_tag_kwds.empty?
        append tag_class.new( *popped_blocks )
      else
        append tag_class.new( *popped_blocks, **new_tag_kwds )
      end
    end
    
    
    def paragraph *fragments
      append Tag::Paragraph.new( *fragments )
    end
    
    alias_method :p, :paragraph
    
    
    def values **values
      append Tag::Values.new( **values )
    end
    
    
    # Shortcut to construct a {Tag::List}.
    # 
    # @param [::Array] args
    #   See {Tag::List#initialize}.
    # 
    # @return [Tag::List]
    # 
    def list *args, &block
      if block.nil?
        Tag::List.new *args
      else
        push Tag::List, *args, &block
      end
    end
    
    
    def item &block
      push Tag::List::Item, &block
    end
    
    
    def code *args, &block
      if block.nil?
        Tag::Code.new *args
      else
        append Tag::Code.new( block.call, *args )
      end
    end
    
    
    def ruby *args, &block
      if block.nil?
        Tag::Code.ruby *args
      else
        append Tag::Code.ruby( block.call, *args )
      end
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
    
    
    def args name = '*args'
      string = name.to_s
      
      unless string[ 0 ] == '*'
        string = '*' + string
      end
      
      ruby Meta::Names::Param::Rest.new( string )
    end
    
    
    def rest name = '*rest'
      args name
    end
    
    
    def kwds name = '**kwds'
      string = name.to_s
      
      unless string.start_with? '**'
        string = '**' + string
      end
      
      ruby Meta::Names::Param::KeyRest.new( string )
    end
    
    
    def kwargs name = '**kwargs'
      kwds name
    end
    
    
    def key_rest name = '**key_rest'
      kwds name
    end
    
    
    # Mark a {::String} as being an actual code {::String}, as opposed to being
    # regular prose.
    # 
    # @return [Tag::Code]
    # 
    def str string
      ruby string
    end
    
    
    # Mark a name ({::String} or similar) as being a Ruby constant name.
    # 
    # @param [#to_s] name
    #   Constant name.
    # 
    # @return [Tag::Code]
    # 
    def const name
      ruby Meta::Names::Const.new( name )
    end
    
    
    def header *fragments
      append Tag::Header.new( *fragments )
    end
    
    
    def section *header_fragments, &block
      if header_fragments.empty?
        push Tag::Section, &block
      else
        push Tag::Section do
          header *header_fragments
          block.call
        end
      end
    end
  
  public # end protected ***************************************************
  
end # class Builder


# /Namespace
# =======================================================================

end # module  Text
end # module  NRSER
