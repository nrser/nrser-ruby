# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ============================================================================

### Stdlib ###

### Deps ###

require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/string/indent'

# Use {Concurrent::Map} for the syntax highlighter cache
require "concurrent/map"

### Project / Package ###

require 'nrser/support/critical_code'

# Using {NRSER::Booly.truthy?}
require 'nrser/booly'

require_relative '../strung'
require_relative '../tag/code'
require_relative './options'


# Namespace
# =======================================================================

module  NRSER
module  Text
module  Renderer


# Definitions
# =======================================================================

# Abstract base class for text renderer instances.
# 
# Renderers render {Tag}s to {::String}s.
# 
# @abstract
# 
# @immutable
#   {Base} itself is practically immutable, through freezing and lack of 
#   mutation APIs, and realizing classes should do the same.
#   
#   This is intended to simplify the use model without thread coordination - 
#   code that has a reference to a renderer can know that it will always 
#   continue to operate in a consistent state.
# 
# @note
#   This class - like everything in {NRSER::Text} - can **not** use any of
#   the {NRSER} error classes ({NRSER::TypeError}, etc.), because those use
#   {NRSER::Text} to render, which will cause a dependency loop.
# 
class Base
  
  # Mixins
  # ==========================================================================
  
  include Support::CriticalCode
  extend  Support::CriticalCode
  
  
  # Attributes
  # ==========================================================================
  
  # Base rendering {Options}.
  # 
  # @return [Options]
  #     
  attr_reader :options
  
  
  # Construction
  # ==========================================================================
  
  # Construct a new {Base}.
  # 
  # @param [Options | ::Hash<(::Symbol | ::String), ::Object> | nil] options
  #   Base options for the renderer. Value is passed to {Options.from} to get 
  #   an {Options} instance, which becomes {#options}.
  #   
  #   When...
  #   
  #   -   {Options} - directly assigned to {#options}.
  #       
  #   -   {::Hash}  - Option name and value pairs pass to {Options#initialize},
  #       assigning over the defaults.
  #       
  #   -   `nil`     - an {Options} is constructed using only it's defaults.
  # 
  # @raise
  #   If {Support::CriticalCode.enabled?} is `false`, bad option values will 
  #   cause an error to be raised. There should be more details in {Options}.
  # 
  def initialize options = nil
    @options = Options.from options
    
    # Use a {Concurrent::Map} for some level of thread safety in the cache
    @syntax_highlighter_cache = Concurrent::Map.new
  end # #initialize
  
  
  # Instance Methods
  # ==========================================================================
  
  # Dump an object to a single-line {Strung}.
  # 
  # For now just calls `#inspect`.
  # 
  # @param [#inspect] value
  #   Pretty much anything.
  # 
  # @return [Strung]
  #   {Strung#source} is the `value`.
  # 
  def dump_value_inline value
    # TODO  Do better!
    Strung.new value.inspect, source: value
  end
  
  
  # Dump a value pretty-like over multiple lines (if needed).
  # 
  # Uses {PP.pp} at the moment.
  # 
  # @param [::Object] value
  #   What to dump. Pretty much anything should be ok.
  # 
  # @param [false | ::Integer] word_wrap
  #   Optional column number to wrap at. If `false`, {PP} will use it's default
  #   of `79`.
  # 
  # @return [Strung]
  #   {Strung#source} will be the `value`.
  # 
  def dump_value_multiline value, word_wrap: self.word_wrap
    Strung.new source: value do |strung|
      args = [ value, strung ]
      args << word_wrap if word_wrap
      PP.pp *args
    end
  end
  
  
  # @!group Syntax Highlighting Instance Methods
  # --------------------------------------------------------------------------
  
  # Get a `::String ⇒ ::String` syntax highlighting `#call`-able for a
  # particular `syntax` - if we can find one.
  #
  #
  # `nil` Syntax
  # --------------------------------------------------------------------------
  #
  # Accepts `nil` for `syntax`, in which case the method always returns `nil`.
  # This is so it can be called like
  #
  #     syntax_highlighter_for code.syntax
  #
  # without first checking if {Tag::Code#syntax} is `nil` (which would mean the 
  # code does not have an associated language syntax).
  #
  #
  # Finding, Caching & Concurrency
  # --------------------------------------------------------------------------
  #
  # Highlight callables are found on-demand by {#find_syntax_highlighter_for},
  # and results are cached internally in a {Concurrent::Map}.
  #
  # **There is no API to clear the cache.** Once a result is there - either
  # `nil` or a callable - it's there for the lifetime of the renderer instance.
  #
  # This is in keeping with the over-arching concurrency approach: once code has
  # a reference to a renderer, it should always stay in a consistent state and
  # behave the same. The only way to achieve different behavior is to use a
  # different renderer instance (see additional notes in the renderer class
  # {Text.default_renderer} method docs).
  #
  # In pursuit of that goal, **{#find_syntax_highlighter_for} is called inside a
  # synchronized block** via {Concurrent::Map#compute_if_absent}.
  #
  # The block will only end up getting run *once*, but if you were to fire a
  # bunch of threads up and have them all try to render text using the same
  # syntax highlighter they will all block until the first to start finishes the
  # find, and finding may take a bit depending on the syntax and
  # implementation... likely at least trying to require some libraries (take a
  # look for a `#<syntax>_syntax_highlighter` method, like
  # {#ruby_syntax_highlighter} - if there isn't one, then the renderer doesn't
  # know how to find any highlighters for that `syntax` and will always return
  # `nil`).
  #
  # It doesn't seem to take much more time to find the highlighters like this
  # (versus with just a single thread), but it definitely takes more
  # *resources*, and if you expected those threads to be available to do useful
  # things like handle connections or some shit, they won't be, so that's
  # something to thing about too.
  #
  # You can avoid this by priming the cache via calling
  # {#syntax_highlighter_for} with each `syntax` you plan to use.
  # 
  # @param [nil | #to_sym] syntax
  #   The syntax name, such as `:ruby`.
  #   
  #   When `nil`, `nil` will always be returned. Otherwise must be a {::Symbol} 
  #   or something that can be cast to one (via `#to_sym`).
  # 
  # @return [nil]
  #   We don't have a highlight `#call`-able available for `syntax`, either 
  #   because:
  #   
  #   1.  `syntax` is `nil`, which *never* has a highlight `#call`-able, or...
  #       
  #   2.  {#find_syntax_highlighter_for} returned `nil` for `syntax` (see 
  #       details there).
  #   
  # @return [#call<(::String) ⇒ ::String>]
  #   A `#call`-able that 
  # 
  def syntax_highlighter_for syntax
    return nil if syntax.nil?
    
    syntax = syntax.to_sym unless syntax.is_a?( ::Symbol )
    
    @syntax_highlighter_cache.compute_if_absent( syntax ) {
      find_syntax_highlighter_for syntax
    }
        
    @syntax_highlighter_cache[ syntax ]
  end
  
  
  # Find a highlighter `#call`-able for a `syntax`.
  # 
  # This is simply a dispatch method that looks for a instance method named 
  # `<syntax>_syntax_highlighter`, and calls it if found (with no arguments).
  # 
  # An example target is {#ruby_syntax_highlighter}.
  # 
  # @note
  #   Unless you are testing or debugging, you probably want to be using 
  #   {#syntax_highlighter_for}, which caches results. This method is broken 
  #   out for ease of development and overriding.
  # 
  # @param [#to_s] syntax
  #   The syntax name, which is used to form the method name to hand off to 
  #   (see above).
  # 
  # @return [nil]
  #   No highlighter is available (at least at this time).
  #   
  #   This happens when `self` does not respond to the computed method name, 
  #   or that method returned `nil`, indicating no highlighter is available.
  # 
  # @return [#call<(::String) ⇒ ::String>]
  #   `#call`-able that transforms source strings into highlighted strings.
  # 
  def find_syntax_highlighter_for syntax
    method_name = "#{ syntax }_syntax_highlighter"
    
    if respond_to?( method_name )
      send method_name
    else
      nil
    end
  end
  
  # @!endgroup Syntax Highlighting Instance Methods # ************************
  
  
  def join *fragments, options: nil
    render_fragments fragments, options
  end
  
end # class Base


# /Namespace
# =======================================================================

end # module  Renderer
end # module  Text
end # module  NRSER
