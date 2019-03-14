# encoding: UTF-8
# frozen_string_literal: true


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
  
  DEFAULT_SPACE = ' '
  
  DEFAULT_NO_PRECEDING_SPACE_CHARS = %w(, ; : . ? !).freeze
  
  
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
                  no_preceding_space_chars: DEFAULT_NO_PRECEDING_SPACE_CHARS
    
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
    
  end # #initialize
  
  
  # Instance Methods
  # ==========================================================================
  
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
  # @param [::String] space
  #   Space string used between adjacent strings when needed.
  # 
  # @return [::String]
  #   Joined string.
  # 
  def join *fragments, with: self.space
    no_space_rhs_regexp = self.no_preceding_space_regexp
    
    fragments.reduce { |lhs_fragment, rhs_fragment|
      lhs_string = string_for lhs_fragment
      rhs_string = string_for rhs_fragment
      
      if no_space_rhs_regexp =~ rhs_string
        lhs_string + rhs_string
      else
        lhs_string + with + rhs_string
      end
    }
  end # .join
  
  
  # Convert a fragment into a {::String} so it can be {.join}ed.
  # 
  # @param [::Object] fragment
  # @return [::String]
  # 
  def string_for fragment
    if fragment.is_a? Text
      return fragment.render self
    end
  
    return fragment.to_summary.to_s if fragment.respond_to?( :to_summary )
    
    return fragment if fragment.is_a?( ::String )
    
    # TODO  Do better!
    fragment.inspect
  end
  
end # class Renderer


# /Namespace
# =======================================================================

end # module  Text
end # module  NRSER
