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

require_relative './strung'
require_relative './tag/code'
require_relative './renderer/options'


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
  
  # Construct a new {Renderer}.
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
  
  # @!endgroup Syntax Highlighting Instance Methods # ************************
  
  
  # @!group Rendering Instance Methods
  # --------------------------------------------------------------------------
  
  # Join assorted `fragments` into a {::String}, attempting to be some-what 
  # smart about it regarding (English) punctuation.
  # 
  # @example Handle fragments that start with punctuation
  #   # that should *not* have whitespace preceding it
  #   a = 'aye'
  #   
  #   ::NRSER::Text::Renderer.new.
  #     render_fragments [ "I've got an", a, ", a bee and a sea." ]
  #   #=> "I've got an aye, a bee and a sea."
  #   
  #   x = "hot dogs"
  #   ::NRSER::Text::Renderer.new.
  #     render_fragments [ "Do you like", x, "?", "Of course you like", x, "!" ]
  #   #=> "Do you like hot dogs? Of course you like hot dogs!"
  # 
  # @param [::Array] fragments
  #   Fragments to be joined. Turned into {::String}s first with 
  #   {.render_fragment}.
  # 
  # @param [nil | Options | Hash] options
  #   Additional rendering options, which will be merged over {#options} for 
  #   use.
  # 
  # @return [::String]
  #   Joined string.
  # 
  def render_fragments fragments, options = nil
    options = self.options.merge options
    
    case fragments.length
    when 0
      return ''
    when 1
      return render_fragment fragments[ 0 ], options
    else
      first, *rest = fragments
    end
  
    no_space_rhs_regexp = options.no_preceding_space_regexp
    
    string = rest.reduce( render_fragment first ) { |lhs_string, rhs_fragment|
      rhs_string = render_fragment rhs_fragment
      
      if no_space_rhs_regexp =~ rhs_string
        lhs_string + rhs_string
      else
        lhs_string + options.join_with + rhs_string
      end
    }
    
    Strung.new string, source: fragments, word_wrap: options.word_wrap
  end # .render_fragments
  
  
  # Render a {Tag} as a block of text.
  # 
  # Acts as a dynamic method router, forming the method name
  # 
  #     "render_#{ tag.render_name }_block"
  # 
  # and calling it with the `tag` and options.
  # 
  # This allows additional tags and {Renderer} extensions that handle them to 
  # be created easily.
  # 
  # Takes care of newline termination as well. If {Options#newline_terminate}
  # is `:detect` on the merged options, a trailing newline is ensured if the 
  # resulting string is more than once line (if it contains `"\n"`).
  # 
  # @param [Options | ::Hash<(::Symbol | ::String), ::Object> | nil] options
  #   Options that will be merged over the base {#options} to use for rendering
  #   the `tag`.
  # 
  # @return [::String]
  #   Rendered string.
  # 
  def render_block tag, options = nil
    options = self.options.merge options
    
    method_name = "render_#{ tag.render_name }_block"
    
    string = send method_name, tag, options
    
    if options.newline_terminate == :detect
      options = options.update :newline_terminate, string.include?( "\n" )
    end
    
    if options.newline_terminate && string[ -1 ] != "\n"
      string = \
        case string
        when Strung
          Strung.new string + "\n", source: string.source
        else
          string + "\n"
        end
    end
    
    string
  end # #render_block
  
  
  # Render a sequence of {Tag}s as blocks, joined by newlines.
  # 
  # Handles newline termination: if {Options#newline_terminate} is `:detect`,
  # then the blocks will be newline-terminated if there is more than one of
  # them.
  # 
  # @param [#map<Tag>] tags
  #   Tags to render.
  # 
  # @param [Options | ::Hash<(::Symbol | ::String), ::Object> | nil] options
  #   Options that will be merged over the base {#options} to use for rendering.
  # 
  # @return [::String]
  # 
  def render_blocks tags, options = nil
    options = self.options.merge options
    
    if options.newline_terminate == :detect && tags.length > 1
      options = options.update :newline_terminate, true
    end
    
    tags.
      map { |tag| render_block tag, options }.
      join "\n"
  end # #render_block
  
  
  # Render a {Tag::List} (or any other tag that's `#render_name` is `list`) as
  # a block.
  # 
  # @param [Tag & #map<Tag>] list
  #   The list to render.
  # 
  # @param [Options | ::Hash<(::Symbol | ::String), ::Object> | nil] options
  #   Options that will be merged over the base {#options} to use for rendering.
  # 
  # @return [::String]
  # 
  def render_list_block list, options = nil
    options = self.options.merge options
    
    # If we are word-wrapping, adjust the size by the list indent.
    if options.word_wrap
      options = options.update  :word_wrap,
                                options.word_wrap - options.list_indent
    end
    
    # Start headers in the items at the list header depth
    options = options.update :header_depth, options.list_header_depth
    
    list.
      map { |item| render_block item, options }.
      join( "\n".indent( options.list_indent, ' ' , true ) )
  end
  
  
  # Render a {Tag::List::Item} (or any other tag that's `#render_name` is 
  # `list_item`) as as block.
  # 
  # @param [Tag & #map<Tag>] list
  #   The list to render.
  # 
  # @param [Options | ::Hash<(::Symbol | ::String), ::Object> | nil] options
  #   Options that will be merged over the base {#options} to use for rendering.
  # 
  # @return [::String]
  # 
  def render_list_item_block item, options = nil
    options = self.options.merge options
    
    rendered = render_blocks  item.blocks,
                              options.update( :newline_terminate, true )
    
    indented = rendered.indent options.list_indent, ' ', true
    indented[0] = '-'
    
    indented
  end
  
  
  def render_paragraph_block paragraph, options = nil
    render_fragments paragraph.fragments, options
  end
  
  
  def render_section_block section, options = nil
    render_blocks section.blocks,
                  self.options.merge( options ).apply( :header_depth, :+, 1 )
  end
  
  
  def render_header_block header, options = nil
    options = self.options.merge options
    
    text = render_fragments header.fragments,
                            options.update( :word_wrap, false )
    
    string = \
      case options.header_depth
      when 0, 1
        if options.word_wrap && options.word_wrap < text.length
          text = text.truncate options.word_wrap
        end
      
        char = if options.header_depth == 0 then '=' else '-' end
        
        "#{ text }\n#{ char * (options.word_wrap || text.length) }"
      else
        sides = '#' * options.header_depth
        sides_length = ( sides.length + 2 ) * 2
        
        if options.word_wrap
          text_max = options.word_wrap - sides_length
          
          if text_max < text.length
            text = text.truncate text_max
          end
        end
        
        "#{ sides } #{ text } #{ sides }"
      end
    
    Strung.new string, source: header
  end # #render_header
  
  
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
  def render_fragment fragment, options = nil
    options = self.options.merge options
    
    if fragment.is_a? Tag::Code
      return render_code fragment, options
    end
    
    if fragment.is_a?( Tag ) && fragment.respond_to?( :render )
      return fragment.render self, options
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
      return render_code( Tag::Code.ruby( fragment ), options )
    end
    
    # We have nothing to do with {::String}s - *including* {Strung}s - so just
    # return them.
    if fragment.is_a?( ::String )
      return fragment
    end
    
    render_code Tag::Code.ruby( dump_value_inline( fragment ) ), options
  end # #render_fragment
  
  
  # Render a {Tag::Code} instance to a {::String} (actually a {::Strung}) for
  # display.
  #
  # Special care has to be taken since {Tag::Code} are created and passed here
  # by {#render_fragment}, while {#render_fragment} also passes any {Tag::Code}
  # it receiver here.
  #
  # In the former case, we need to be careful *not* to pass the
  # {Tag::Code#source} back to {#render_fragment} because it would cause an
  # infinite loop, while in the latter case we want to pass the
  # {Tag::Code#source} to {#render_fragment} to get a {::String} for it.
  #
  # @param [Tag::Code] code
  #   The code.
  # 
  # @return [Strung]
  #   A string strung from the `code`
  # 
  def render_code code, options = nil
    options = self.options.merge options
    
    source_string = \
      case code.source
      when ::Class
        # {::Class} needs special handling to prevent an infinite loop
        code.source.to_s
      when ::String # including {::Strung}!
        # Just use the {Tag::Code#source}, no need to pass it back through
        # {#render_fragment}. This saves us time and possible problems with
        # {Tag::Code} instances created from calling `#inspect` on Ruby objects
        # (last lines of {#render_fragment})
        code.source
      else
        # The rest should be ok to go back through {#render_fragment} since they
        # weren't created there
        render_fragment code.source, options
      end
    
      if  options.color? &&
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
            code.source.name # &&
            # yard_style_class_names?
        # {Tag::Code#source} is a named (non-anonymous) {::Class}, which we
        # "curly quote" (like YAML doc-strings)
        Tag::Code.curly_quote( code.source.name )
      
      else
        Tag::Code.backtick_quote( source_string )
      
      end
    
    Strung.new rendered_string, source: code
  end # #render_code
  
  
  # Render a {Tag::Code} as a block of text.
  # 
  # @param [Tag::Code] code
  #   The code tag.
  # 
  # @param [false | ::Integer] word_wrap
  #   Column to wrap lines at.
  # 
  # @param [::Hash<::Symbol, ::Object>] **options
  #   
  # @return [Strung]
  #   Rendered string.
  # 
  def render_code_block code, options = nil
    options = self.options.merge options
    
    if options.word_wrap
      options = options.apply :word_wrap, :-, options.code_indent
    end
    
    strung = if code.source.is_a? Strung
      code.source
    else
      dump_value_multiline code.source, word_wrap: options.word_wrap
    end
    
    if  options.color? &&
        (highlighter = syntax_highlighter_for code.syntax)
      
      highlighted_string = try_critical_code(
        get_message: -> {
          "{#{ self.class }} failed to highlight syntax #{ code.syntax }"
        }
      ) do
        highlighter.call strung
      end
      
      unless highlighted_string.nil?
        strung = Strung.new highlighted_string, source: strung.source
      end
    end # Highlighting
    
    Strung.new strung.indent( options.code_indent, ' ', true ),
      source: strung.source
  end # #render_code_block
  
  
  def render_values_block values, options = nil
    options = self.options.merge options
    
    max_name_length = values.keys.map { |k| k.to_s.length }.max
    
    separator = ' = '
    label_col_width = separator.length + max_name_length
    
    word_wrap = options.word_wrap && (options.word_wrap - label_col_width)
    
    code_string = values.
      map { |name, value|
        dump = dump_value_multiline value, word_wrap: word_wrap
        
        label = name.to_s.ljust( max_name_length ) + separator
        
        string = dump.indent label_col_width, ' ', true
        
        string[ 0...label.length ] = label
        
        string
      }.
      join( "\n" )
    
    strung = Strung.new code_string, source: values
    
    render_code_block Tag::Code.ruby( strung ), options
    
  end # #render_values_block
  
  # @!endgroup Rendering Instance Methods # **********************************
  
end # class Renderer


# /Namespace
# =======================================================================

end # module  Text
end # module  NRSER
