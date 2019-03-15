# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ============================================================================

### Stdlib ###

### Deps ###

### Project / Package ###

require 'nrser/ext/object/booly'

require_relative './strung'


# Namespace
# =======================================================================

module  NRSER
module  Text


# Definitions
# =======================================================================

# Render ordered fragment objects together into a final {::String}.
# 
# @note
#   This class - like everything in {NRSER::Text} - can **not** use any of
#   the {NRSER} error classes ({NRSER::TypeError}, etc.), because those use
#   {NRSER::Text} to render, which will cause a dependency loop.
# 
# @note
#   {Renderer} instances are practically immutable. Change rendering 
#   characteristics by creating and using new instances.
#   
#   This is intended to simplify the use model without thread coordination - 
#   code that has a reference to a {Renderer} can know that it will always 
#   continue to operate in a consistent state.
#   
#   See details for how this works in the general case in 
#   {Text.default_renderer}.
# 
class Renderer

  # Constants
  # ==========================================================================
  
  # Instance Defaults
  # ----------------------------------------------------------------------------
  
  # Default character to use for {#space}. Just the regular ASCII space 
  # character.
  # 
  # @return [String]
  # 
  DEFAULT_SPACE = ' '
  
  
  # Default characters to use for {#no_preceding_space_chars}, which is used to
  # form {#no_preceding_space_regexp}.
  # 
  # @return [::Array<::String>]
  # 
  DEFAULT_NO_PRECEDING_SPACE_CHARS = %w(, ; : . ? !).freeze
  
  
  # Default for {#yard_style_class_names?}.
  # 
  # @return [Boolean]
  # 
  DEFAULT_YARD_STYLE_CLASS_NAMES = true
  
  
  # Singleton Methods
  # ==========================================================================
  
  # 
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.default_color?
    if ENV.key? 'NRSER_TEXT_USE_COLOR'
      return Ext::Object::truthy? ENV[ 'NRSER_TEXT_USE_COLOR' ]
    end
    
    # Detect based on environment
    # 
    # Borrowed from Thor (MIT license)
    # 
    # https://github.com/erikhuda/thor/blob/0887bc8fb257fadf656fb4c4f081a9067b373e7b/lib/thor/shell.rb#L14
    # 
    !( RbConfig::CONFIG["host_os"] =~ /mswin|mingw/ && !ENV["ANSICON"] )
  end # .default_color?
  
  
  # Attributes
  # ==========================================================================
  
  # Space string to join adjacent fragment strings that look like they need it.
  # 
  # @immutable Frozen
  # 
  # @return [::String]
  #     
  attr_reader :space
  
  
  # Punctuation characters used to build the {#no_preceding_space_regexp}
  # {::Regexp}.
  # 
  # @immutable Deeply frozen.
  # 
  # @return [::Array<::String>]
  #     
  attr_reader :no_preceding_space_chars
  
  
  # Construction
  # ==========================================================================
  
  # Construct a new {Renderer}.
  # 
  # @param [::String] space
  #   String to use between fragments in {#join} (unless overridden in that call
  #   itself). Assigned to {#space}.
  # 
  # @param [::Array<::String>] no_preceding_space_chars
  #   Characters that usually should not have a space in front of them in 
  #   English. Assigned to {#no_preceding_space_chars} and used to be a little
  #   smarter in {#join}.
  # 
  # @raise [::TypeError]
  #   If `space` is not a {::String}.
  # 
  # @raise [::TypeError]
  #   If all entries in `no_preceding_space_chars` are not {::String}s.
  # 
  def initialize  space: DEFAULT_SPACE,
                  no_preceding_space_chars: DEFAULT_NO_PRECEDING_SPACE_CHARS,
                  yard_style_class_names: DEFAULT_YARD_STYLE_CLASS_NAMES,
                  color: self.class.default_color?
    
    unless space.is_a? ::String
      # NOTE  Can't use {NRSER::TypeError}
      raise ::TypeError,
        "`space:` argument must be a {String}, given #{ space.class }: " +
        space.inspect
    end
    
    @space = space.freeze
    
    @no_preceding_space_chars = \
      no_preceding_space_chars.map { |entry|
        unless entry.is_a? ::String
          # NOTE  Can't use {NRSER::TypeError} 'cause it uses text stuff to 
          #       render! See note in class doc-string.
          raise ::TypeError,
            "Entries in `no_preceding_space_chars:` must be {String}s," +
            "given #{ entry.class }: #{ entry.inspect }"
        end
        
        entry.freeze
      }.freeze
    
    @yard_style_class_names = !!yard_style_class_names
    
    @color = !!color
    
    @syntax_highlighter_cache = {}
    
  end # #initialize
  
  
  # Instance Methods
  # ==========================================================================
  
  # When true renders {::Class} fragments in YARD link style like
  # 
  #     "{String}"
  # 
  # @return [Boolean]
  # 
  def yard_style_class_names?
    @yard_style_class_names
  end # #yard_style_class_names?
  
  
  # @todo Document color? method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def color?
    @color
  end # #color?
  
  
  # Regular expression to test against the right-hand side (RHS) {::String} of
  # a {.join} to see if we should omit the separating space character.
  # 
  # Basically, does the RHS start with a punctuation character that should *not*
  # have a space in front of it?
  # 
  # This is all English-only at the moment.
  # 
  # @return [Regexp]
  #   
  def no_preceding_space_regexp
    /\A[#{ Regexp.escape no_preceding_space_chars.join }](?:[[:space:]]|$)/
  end
  
  
  def syntax_highlighter_for syntax
    return nil if syntax.nil?
    
    syntax = syntax.to_sym unless syntax.is_a?( ::Symbol )
    
    unless @syntax_highlighter_cache.key? syntax
      @syntax_highlighter_cache[ syntax ] = find_syntax_highlighter_for syntax
    end
        
    @syntax_highlighter_cache[ syntax ]
  end
  
  
  def find_syntax_highlighter_for syntax
    method_name = "#{ syntax }_syntax_highlighter"
    
    if respond_to?( method_name )
      send method_name
    else
      nil
    end
  end
  
  
  def ruby_syntax_highlighter
    require 'rspec'
    highlighter = \
      ::RSpec::Core::Formatters::SyntaxHighlighter.new ::RSpec.configuration
    
    ->( string ) { highlighter.highlight( string.lines ).join }
  rescue
    nil
  end
  
  
  # Join assorted `fragments` into a {::String}, attempting to be some-what 
  # smart about it regarding (English) punctuation.
  # 
  # @example Handle fragments that start with punctuation
  #   # that should *not* have whitespace preceding it
  #   a = 'aye'
  #   
  #   Renderer.new.join "I've got an", a, ", a bee and a sea."
  #   #=> "I've got an aye, a bee and a sea."
  #   
  #   x = "hot dogs"
  #   Rendered.new.join "Do you like", x, "?", "Of course you like", x, "!"
  #   #=> "Do you like hot dogs? Of course you like hot dogs!"
  # 
  # @param [::Array] fragments
  #   Fragments to be joined. Turned into {::String}s first with {.string_for}.
  # 
  # @param [::String] with
  #   String to join with.
  # 
  # @return [::String]
  #   Joined string.
  # 
  def join *fragments, with: self.space
    no_space_rhs_regexp = self.no_preceding_space_regexp
    
    string = fragments.reduce { |lhs_fragment, rhs_fragment|
      lhs_string = string_for lhs_fragment
      rhs_string = string_for rhs_fragment
      
      if no_space_rhs_regexp =~ rhs_string
        lhs_string + rhs_string
      else
        lhs_string + with + rhs_string
      end
    }
    
    Strung.new string, source: fragments
  end # .join
  
  
  # Get the display string for an individual `fragment`.
  #
  # A {::String} instance is always returned. 
  #
  # In most cases, what is returned is actually a {Strung} - a {::String}
  # extension that saves the object it was created from as an instance variable,
  # allowing better decision making later if you want to truncate or ellipsis
  # it.
  #
  # The only case in which a {::String} is returned that is *not* a {::Strung} 
  # is when a {::String} that is not a {::Strung} and that does not match any
  # if the other formatting tests is given as the `fragment`. In such case,
  # there's not anything useful that can be done with it.
  # 
  # @param [::Object] fragment
  #   Fragment object you want the string for. Should handle anything;
  #   behavior depends on the object's class and this instance's configuration.
  # 
  # @return [::String]
  #   String representation of the `fragment` ready for display.
  # 
  def string_for fragment
    if fragment.is_a? Text
      return fragment.render self
    end
    
    if fragment.respond_to? :to_strung
      return fragment.to_strung
    end
    
    # TODO  This is old shit brought over from 
    #       `//lib/nrser/functions/text/format.rb` that probably should be 
    #       superceded by the stuff being laid out in the {NRSER::Text} module.
    #       
    #       I think very little ended up implementing it anyways, only seeing 
    #       10 hits in 6 files with a quick search (2019.03.15)
    #       
    if fragment.respond_to? :to_summary
      summary = fragment.to_summary
      
      case summary
      when Strung
        return summary
      when ::String
        return Strung.new summary, source: fragment
      else
        return Strung.new summary.to_s, source: fragment
      end
    end # if #to_summary
    
    if fragment.is_a?( ::Class ) && yard_style_class_names?
      return Strung.new "{#{ fragment.to_s }}", source: fragment
    end
    
    # We have nothing to do with {::String}s - *including* {Strung}s - so just
    # return them.
    if fragment.is_a?( ::String )
      return fragment
    end
    
    # TODO  Do better!
    Strung.new fragment.inspect, source: fragment
  end # #string_for
  
  
end # class Renderer


# /Namespace
# =======================================================================

end # module  Text
end # module  NRSER
