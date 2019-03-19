# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ============================================================================

### Stdlib ###

### Deps ###

require 'active_support/core_ext/string/inflections'

# Use {Concurrent::Map} for the syntax highlighter cache
require "concurrent/map"

### Project / Package ###

require 'nrser/support/critical_code'

require 'nrser/ext/object/booly'

require_relative './strung'
require_relative './code'


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
  
  
  # Mixins
  # ==========================================================================
  
  include Support::CriticalCode
  
  
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
  
  
  # Default positive {::Integer} column to wrap text at, or `false` for no 
  # wrapping.
  # 
  # @return [false]
  # 
  def self.default_word_wrap
    false
  end # .default_word_wrap
  
  
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
  
  
  # Column to wrap text at, if any.
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
                  color: self.class.default_color?,
                  word_wrap: self.class.default_word_wrap
    
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
    
    @word_wrap = \
      case word_wrap
      when nil
        self.class.default_word_wrap
      when false
        false
      when ::Integer
        if word_wrap > 0
          word_wrap
        else
          warn "Bad `word_wrap:` argument: #{ word_wrap }. Using `nil`."
          self.class.default_word_wrap
        end
      else
        warn "Bad `word_wrap:` argument: #{ word_wrap.inspect }"
        self.class.default_word_wrap
      end
    
    # Use a {Concurrent::Map} for some level of thread safety in the cache
    @syntax_highlighter_cache = Concurrent::Map.new
    
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
  
  
  # Get a `::String → ::String` syntax highlighting `#call`-able for a
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
  # without first checking if {Code#syntax} is `nil` (which would mean the code
  # does not have an associated language syntax).
  #
  #
  # Finding, Caching & Concurrency
  # --------------------------------------------------------------------------
  #
  # Highlight callables are found on-demand by {#find_syntax_highlighter_for},
  # and results are cached internally in a {Concurrent::Map}.
  #
  # **There is no API to clear the cache.** Once a result is there - either
  # `nil` or a callable - it's there for the lifetime of the {Renderer}
  # instance.
  #
  # This is in keeping with the over-arching concurrency approach: once code has
  # a reference to a {Renderer}, it should always stay in a consistent state and
  # behave the same. The only way to achieve different behavior is to use a
  # different {Renderer} instance (see additional notes in the {Renderer} class
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
  # {#ruby_syntax_highlighter} - if there isn't one, then the {Renderer} doesn't
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
  # @return [#call<(::String) → ::String>]
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
  # @return [#call<(::String) → ::String>]
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
  
  
  # `#call`-able to highlight Ruby syntax, if any are available.
  # 
  # Tries to require `rspec`, and uses 
  # {::RSpec::Core::Formatters::SyntaxHighlighter} if available.
  # 
  # @return [nil]
  #   If not Ruby syntax highlighter is available.
  # 
  # @return [::Proc<(::String) -> (::String)]
  #   When a syntax highlighter is available, a {::String} transformer to 
  #   highlight Ruby code.
  # 
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
  #   Fragments to be joined. Turned into {::String}s first with {.render_fragment}.
  # 
  # @param [::String] with
  #   String to join with.
  # 
  # @return [::String]
  #   Joined string.
  # 
  def render_fragments  *fragments,
                        with: self.space,
                        word_wrap: self.word_wrap,
                        **options
    case fragments.length
    when 0
      return ''
    when 1
      return render_fragment fragments[ 0 ]
    else
      first, *rest = fragments
    end
  
    no_space_rhs_regexp = self.no_preceding_space_regexp
    
    string = rest.reduce( render_fragment first ) { |lhs_string, rhs_fragment|
      rhs_string = render_fragment rhs_fragment
      
      if no_space_rhs_regexp =~ rhs_string
        lhs_string + rhs_string
      else
        lhs_string + with + rhs_string
      end
    }
    
    Strung.new string, source: fragments, word_wrap: word_wrap
  end # .render_fragments
  
  alias_method :join, :render_fragments
  
  
  def render_block tag, newline_terminate: nil, **options
    method_name = "render_#{ tag.class.name.demodulize.downcase }"
    
    string = send method_name, tag, **options
    
    if newline_terminate.nil?
      newline_terminate = string.include? "\n"
    end
    
    if newline_terminate && string[ -1 ] != "\n"
      string = \
        case string
        when Strung
          Strung.new string + "\n", source: string.source
        else
          string + "\n"
        end
    end
    
    string
  end
  
  
  def render_blocks *tags, **options
    tags.
      map { |tag|
        render_block tag, **options,
          newline_terminate: (if tags.length > 1 then true else nil end)
      }.
      join "\n"
  end
  
  
  def render_paragraph paragraph, **options
    render_fragments *paragraph.fragments, **options
  end
  
  
  def render_section section, depth: 0, **options
    render_blocks *section.blocks, depth: (depth + 1), **options
  end
  
  
  def render_header header, depth: 0, word_wrap: self.word_wrap, **options
    text = render_fragments *header.fragments, **options, word_wrap: false
    
    string = \
      case depth
      when 0, 1
        if word_wrap && word_wrap < text.length
          text = text.truncate word_wrap
        end
      
        char = if depth == 0 then '=' else '-' end
        
        "#{ text }\n#{ char * (word_wrap || text.length) }"
      else
        sides = '#' * depth
        sides_length = ( sides.length + 2 ) * 2
        
        if word_wrap
          text_max = word_wrap - sides_length
          
          if text_max < text.length
            text = text.truncate text_max
          end
          
          "#{ sides } #{ text } #{ sides }"
        end
      end
    
    Strung.new string, source: header
  end
  
  
  # Render a display string for an individual `fragment`.
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
  def render_fragment fragment
    if fragment.is_a? Code
      return render_code fragment
    end
    
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
    
    # if fragment.is_a?( ::Class ) && yard_style_class_names?
    #   return Strung.new "{#{ fragment.to_s }}", source: fragment
    # end
    
    if fragment.is_a?( ::Class )
      return render_code( Code.ruby fragment )
    end
    
    # We have nothing to do with {::String}s - *including* {Strung}s - so just
    # return them.
    if fragment.is_a?( ::String )
      return fragment
    end
    
    # TODO  Do better!
    render_code \
      Code.ruby( Strung.new( fragment.inspect, source: fragment ) )
  end # #render_fragment
  
  
  # Render a {Code} instance to a {::String} (actually a {::Strung}) for
  # display.
  #
  # Special care has to be taken since {Code} are created and passed here by
  # {#render_fragment}, while {#render_fragment} also passes any {Code} it
  # receiver here.
  #
  # In the former case, we need to be careful *not* to pass the {Code#source}
  # back to {#render_fragment} because it would cause an infinite loop, while in
  # the latter case we want to pass the {Code#source} to {#render_fragment} to
  # get a {::String} for it.
  #
  # @param [Code] code
  #   The code.
  # 
  # @return [Strung]
  #   A string strung from the `code`
  # 
  def render_code code
    source_string = \
      case code.source
      when ::Class
        # {::Class} needs special handling to prevent an infinite loop
        code.source.to_s
      when ::String # including {::Strung}!
        # Just use the {Code#source}, no need to pass it back through 
        # {#render_fragment}. This saves us time and possible problems with {Code}
        # instances created from calling `#inspect` on Ruby objects (last lines
        # of {#render_fragment})
        code.source
      else
        # The rest should be ok to go back through {#render_fragment} since they
        # weren't created there
        render_fragment code.source
      end
    
      if  color? &&
          (highlighter = syntax_highlighter_for code.syntax)
        
        highlighted_string = try_critical_code(
          get_message: -> {
            "{#{ self.class }} failed to highlight syntax #{ code.syntax }"
          }
        ) do
          highlighter.call source_string
        end
        
        unless highlighted_string.nil?
          return Strung.new highlighted_string, source: code
        end

        # Fall through...
      end
    
      rendered_string = \
        if code.source.is_a?( ::Class ) &&
            code.source.name &&
            yard_style_class_names?
        # {Code#source} is a named (non-anonymous) {::Class}, which we "curly
        # quote" (like YAML doc-strings)
        Code.curly_quote( code.source.name )
      
      else
        Code.backtick_quote( source_string )
      
      end
    
    Strung.new rendered_string, source: code
  end # #render_code
  
end # class Renderer


# /Namespace
# =======================================================================

end # module  Text
end # module  NRSER
