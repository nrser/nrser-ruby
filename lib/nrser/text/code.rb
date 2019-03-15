# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Stdlib ###

### Deps ###

### Project / Package ###

require 'nrser/text'


# Refinements
# =======================================================================


# Namespace
# =======================================================================

module  NRSER
module  Text


# Definitions
# =======================================================================

# @todo document Code class.
# 
class Code
  
  # Mixins
  # ==========================================================================
  
  include Text
  
  
  # Singleton Methods
  # ==========================================================================
  
  # Shortcut to construct an instance with `:ruby` {#syntax}.
  # 
  # @param [::Object] source
  #   Source object for the code.
  # 
  # @return [Code]
  # 
  def self.ruby source
    new source, syntax: :ruby
  end # .ruby
  
  
  # @todo Document quote method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.quote string
    quote = '`' * ((string.scan( /`+/ ).map( &:length ).max || 0) + 1)
    "#{ quote }#{ string }#{ quote }"
  end # .quote
  
  
  # Attributes
  # ==========================================================================
  
  # The code object.
  # 
  # @return [::Object]
  #     
  attr_reader :source
  
  
  # Syntax (language) of the code, if any.
  # 
  # @return [nil]
  #   This {Code} has not associated syntax.
  # 
  # @return [::Symbol]
  #   Name of the syntax (`:ruby`, etc...).
  #     
  attr_reader :syntax
  
  
  # Construction
  # ==========================================================================
  
  # Instantiate a new `Code`.
  def initialize source, syntax: nil
    @source = source
    
    @syntax = if syntax.nil?
      syntax
    else
      syntax.to_sym
    end
  end # #initialize
  
  
  # Instance Methods
  # ==========================================================================
  
  # Render the {Code} into a final display string.
  # 
  # @param [Renderer] renderer
  #   {Renderer} to use.
  # 
  # @return [Strung]
  #   Rendered string with {#source} attached as it's {Strung#source}.
  # 
  def render renderer = Text.default_renderer
    string = renderer.string_for source
    
    if  renderer.color? &&
        (highlighter = renderer.syntax_highlighter_for syntax)
      Strung.new highlighter.call( string ), source: source
    else
      Strung.new self.class.quote( string ), source: source
    end
  end # #render
  
end # class Code


# /Namespace
# =======================================================================

end # module  Text
end # module  NRSER
