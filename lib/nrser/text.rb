# encoding: UTF-8
# frozen_string_literal: true
# doctest: true

# Requirements
# =======================================================================

### Stdlib ###

require 'set'

### Deps ###

require 'active_support/core_ext/module/attribute_accessors'

### Project / Package ###

require_relative './text/renderer'


# Namespace
# =======================================================================

module  NRSER


# Definitions
# =======================================================================

# @todo document Text module.
# 
module Text
  
  # Ah, threading...
  # 
  # Set here to avoid potential re-entry weirdness that I think could happen
  # using common "create on-demand" semantics where one thread sets the 
  # default {Renderer} using {.default_renderer=} while another is getting the
  # default {Renderer} using {.default_renderer} and the set of
  # `@default_renderer` in {.default_renderer=} occurs **between** when 
  # {.default_renderer} sees that `@default_renderer` is `nil` (never yet set)
  # and when it assigns `@default_renderer = Renderer.new`, which seems like it
  # would clobber the {Renderer} set by {.default_renderer=}.
  # 
  @default_renderer = Renderer.new
  
  
  # Singleton Methods
  # ==========================================================================
  
  # Get the default {Renderer}, which is used in the {.join} and {.string_for}
  # shortcuts.
  # 
  # @note
  #   This class - like everything in {NRSER::Text} - can **not** use any of
  #   the {NRSER} error classes ({NRSER::TypeError}, etc.), because those use
  #   {NRSER::Text} to render, which will cause a dependency loop.
  # 
  # @note
  #   Mutability and Threading
  #   ------------------------------------------------------------------------
  #   
  #   The default {Renderer} may be changed by setting the reference via
  #   {.default_renderer=}, but the {Renderer} instances themselves are meant to 
  #   be practically immutable.
  #   
  #   This means that once some code has a reference to a {Renderer}, it should
  #   continue to operate in a consistent state, **but** each time they get a 
  #   reference it **may be a different instance with different behavior**.
  #   
  #   This is intended to offer flexibility to change the default rendering 
  #   behavior at runtime without needing nuanced and expensive mutation 
  #   semantics, but it does require awareness when using the default renderer:
  #   
  #   > Code implementing a logical rendering operation should generally access 
  #   > the default renderer **once** and use that {Renderer} for all rendering 
  #   > needs in that logical operation, in order to ensure consistent behavior
  #   > across calls.
  #   
  #   This is probably most important in loops. You generally **DO NOT** want to 
  #   use code like this (contrived) example:
  #   
  #   ```ruby
  #   # BAD BAD BAD!!! DON'T DO THIS:
  #   strings = my_stuff.map { |entry|
  #     # NO NO NO! {NRSER::Text.string_for} will pull a *new* reference every
  #     # iteration, which has no guarantee to be the instance!
  #     NRSER::Text.string_for entry
  #   }
  #   ```
  #   
  #   Much better:
  #   
  #   ```ruby
  #   renderer = NRSER::Text.default_renderer
  #   my_stuff.map { |entry| renderer.string_for entry }
  #   ```
  #   
  #   **Best** - use the yielding form so you don't forget!
  #   
  #   ```ruby
  #   NRSER::Text.default_renderer do |renderer|
  #     my_stuff.map { |entry| renderer.string_for entry }
  #   end
  #   ```
  # 
  # @overload default_renderer
  #   Get a reference to the current {Renderer} instance. Please note the 
  #   warning above.
  #   
  #   @return [Renderer]
  #   
  # @overload default_renderer &block
  #   Yields the default {Renderer} to a block for use, and returns whatever 
  #   that `&block` returns.
  #   
  #   **This is the preferred form for usage**; see the note above.
  #   
  #   @param [Proc<(Renderer) ⇒ ::Object>] block
  #   
  #   @return [::Object]
  #     
  # 
  def self.default_renderer &block
    if block
      block.call @default_renderer
    else
      @default_renderer
    end
  end
  
  
  # Change the default {Renderer} used in {.join}, {.string_for}, etc.
  # 
  # @param [Renderer] renderer
  #   {Renderer} to assign.
  # 
  # @return [Renderer]
  #   The `renderer` passed in.
  # 
  # @raise [::TypeError]
  #   If `renderer` is not a {Renderer}.
  # 
  def self.default_renderer= renderer
    unless renderer.is_a? Renderer
      raise ::TypeError,
        "Must be a {NRSER::Text::Renderer}, given #{ renderer.class }: " +
        renderer.inspect
    end
    
    @default_renderer = renderer
  end
  
  
  # Join assorted `fragments` into a {::String}, attempting to be some-what 
  # smart about it regarding (English) punctuation.
  # 
  # @example Handle fragments that start with punctuation
  #   # that should *not* have whitespace preceding it
  #   a = 'aye'
  #   
  #   join "I've got an", a, ", a bee and a sea."
  #   #=> "I've got an aye, a bee and a sea."
  #   
  #   x = "hot dogs"
  #   join "Do you like", x, "?", "Of course you like", x, "!"
  #   #=> "Do you like hot dogs? Of course you like hot dogs!"
  # 
  # @param [::Array] fragments
  #   Fragments to be joined. Turned into {::String}s first with {.string_for}.
  # 
  # @param [::Hash<::Symbol, ::Object>] options
  #   Keyword options to pass to {Renderer#join}.
  # 
  # @return [::String]
  #   Joined string.
  # 
  def self.join *fragments, **options
    default_renderer.join *fragments, **options
  end # .join
  
  
  # Render a fragment into a {::String} using the {.default_renderer}.
  # 
  # @see Renderer#render_fragment
  # @see .default_renderer
  # 
  # @param [::Object] fragment
  # @return [::String]
  # 
  def self.render_fragment fragment
    default_renderer.render_fragment fragment
  end
  
  
  # @todo Document build method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.build *args, &block
    require_relative './text/builder'
    
    Builder.new *args, &block
  end # .build
  
end # module Text


# /Namespace
# =======================================================================

end # module  NRSER
