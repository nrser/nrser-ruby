# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Stdlib
# ------------------------------------------------------------------------

# Using {PP.pp} as default dumper.
require 'pp'

require 'nrser/core_ext/object/lazy_var'


# Definitions
# =======================================================================

# A mixin for {Exception} and utilities to make life better... even when things
# go wrong.
# 
# "Nicer" errors do a few things:
# 
# 1.  **`message` is a splat/`Array`**
#     
#     Accept an {Array} `message` instead of just a string, dumping non-string
#     values and joining everything together.
#     
#     This lets you deal with printing/dumping all in one place instead of
#     ad-hoc'ing `#to_s`, `#inspect`, `#pretty_inspect`, etc. all over the
#     place (though you can still dump values yourself of course since string
#     pass right through).
#     
#     Write things like:
# 
#         MyError.new "The value", value, "sucks, it should be", expected
# 
#     This should cut down the amount of typing when raising as well, which
#     is always welcome.
#     
#     It also allows for a future where we get smarter about dumping things,
#     offer configuration options, switch on environments (slow, rich dev
#     versus fast, concise prod), etc.
# 
# 2.  **"Extended" Messages**
#     
#     The normal message that we talked about in (1) - that we call the
#     *summary message* or *super-message* (since it gets passed up to the
#     built-in Exception's `#initialize`) - is intended to be:
#     
#     1.  Very concise
#         -   A single line well under 80 characters if possible.
#             
#         -   This just seems like how Ruby exception messages were meant to
#             be, I guess, and in many situations it's all you would want or
#             need (production, when it just gets rescued anyways,
#             there's no one there to read it, etc.).
#             
#     2.  Cheap to render.
#         -   We may be trying to do lot very quickly on a production system.
#     
#     However - especially when developing - it can be really nice to add
#     considerably more detail and feedback to errors.
#     
#     To support this important use case as well, `NicerError` introduces the
#     idea of an *extended message* that does not need to be rendered and
#     output along with the *summary/super-message*.
#     
#     It's rendering is done on-demand, so systems that are not configured to
#     use it will pay a minimal cost for it's existence.
#     
#     > See {#extended_message}.
#     
#     The extended message is composed of:
#     
#     1.  Text *details*, optionally rendered via {Binding.erb} when a
#         binding is provided.
#     
#     2.  A *context* of name and value pairs to dump.
#         
#     Both are provided as optional keyword parameters to {#initialize}.
# 
module NRSER::NicerError
  
  # Constants
  # ========================================================================
  
  # Default column width
  DEFAULT_COLUMN_WIDTH = 78
  
  
  # Module Methods
  # ==========================================================================
  
  # Column width to format for (just summary/super-message at the moment).
  # 
  # @todo
  #   Implement terminal width detection like Thor?
  # 
  # @return [Fixnum]
  #   Positive integer.
  # 
  def self.column_width
    DEFAULT_COLUMN_WIDTH
  end
  
  
  # Construct a nicer error.
  # 
  # @param [Array] *message
  #   Main message segments.
  # 
  # @param [Binding?] binding:
  #   When provided any details string will be rendered using it's
  #   {Binding#erb} method.
  # 
  # @param [nil | String | Proc<()=>String> | #to_s] details:
  #   Additional text details to add to the extended message. When:
  #   
  #   1.  `nil` - no details will be added.
  #       
  #   2.  `String` - the value will be used. If `binding:` is provided, it
  #       will be rendered against it as ERB.
  #       
  #   3.  `Proc<()=>String>` - if and when an extended message is needed
  #       the proc will be called, and the resulting string will be used
  #       as in (2).
  #       
  #   4.  `#to_s` - catch all; if and when an extended message is needed
  #       `#to_s` will be called on the value and the result will be used
  #       as in (2).
  # 
  # @param [Hash<Symbol, VALUE>] **context
  #   Any additional names and values to dump with an extended message.
  # 
  def initialize  *message,
                  binding: nil,
                  details: nil,
                  **context
    @binding = binding
    @context = context
    @details = details
    
    message = default_message if message.empty?
    super_message = format_message *message
    
    super super_message
  end # #initialize
  
  
  # Format a segment of the error message.
  # 
  # Strings are simply returned. Other things are inspected (for now).
  # 
  # @param [Object] segment
  #   The segment.
  # 
  # @return [String]
  #   The formatted string for the segment.
  # 
  def format_message_segment segment
    return segment.to_summary if segment.respond_to?( :to_summary )
    
    return segment if String === segment
    
    # TODO  Do better!
    segment.inspect
  end # #format_message_segment
  
  
  # Format the main message by converting args to strings and joining them.
  # 
  # @param [Array] *message
  #   Message segments.
  # 
  # @return [String]
  #   Formatted and joined message ready to pass up to the built-in
  #   exception's `#initialize`.
  # 
  def format_message *message
    message.map( &method( :format_message_segment ) ).join( ' ' )
  end
  
  
  # Main message to use when none provided to {#initialize}.
  # 
  # @return [String]
  # 
  def default_message
    "(no message)"
  end
  
  
  # Any additional context values to add to extended messages provided to
  # {#initialize}.
  # 
  # @return [Hash<Symbol, *>]
  # 
  def context
    @context
  end
  
  
  def details
    @details
  end
  
  
  # Render details (first time only, then cached) and return the string.
  # 
  # @return [String?]
  # 
  def details_section
    lazy_var :@details_section do
      # No details if we have nothing to work with
      if details.nil?
        nil
      else
        contents = case details
        when Proc
          details.call
        when String
          details
        else
          details.to_s
        end
        
        if contents.empty?
          nil
        else
          if @binding
            contents = binding.erb contents
          end
          
          "# Details\n\n" + contents
        end
      end
    end
  end
  
  
  # @return [String?]
  # 
  def context_section
    lazy_var :@context_section do
      if context.empty?
        nil
      else
        "# Context:\n\n" + context.map { |name, value|
          name_str = name.to_s
          value_str = PP.pp \
            value,
            ''.dup,
            (NRSER::NicerError.column_width - name_str.length - 2)
          
          if value_str.lines.count > 1
            "#{ name_str }:\n\n#{ value_str.indent 4 }\n"
          else
            "#{ name_str }: #{ value_str }\n"
          end
        }.join
      end
    end
  end
  
  
  # Return the extended message, rendering if necessary (cached after first
  # call).
  # 
  # @return [String]
  #   Will be empty if there is no extended message.
  # 
  def extended_message
    @extended_message ||= begin
      sections = []
      
      sections << details_section unless details_section.nil?
      sections << context_section unless context_section.nil?
      
      joined = sections.join "\n\n"
    end
  end
  
  
  # Should we add the extended message to {#to_s} output?
  # 
  # @todo
  #   Just returns `true` for now... should be configurable in the future.
  # 
  # @return [Boolean]
  # 
  def add_extended_message?
    true
  end
  
  
  # Get the message or the extended message.
  # 
  # @note
  #   This is a bit weird, having to do with what I can tell about the
  #   built-in errors and how they handle their message - they have *no*
  #   instance variables, and seem to rely on `#to_s` to get the message
  #   out of C-land, however that works.
  #   
  #   {Exception#message} just forwards here, so I overrode that with
  #   {#message} to just get the *summary/super-message* from this method.
  # 
  # @param [Boolean?] extended:
  #   Flag to explicitly control summary/super or extended message:
  #   
  #   1.  `nil` - call {#add_extended_message?} to decide (default).
  #   2.  `false` - return just the *summary/super-message*.
  #   3.  `true` - always add the *extended message* (unless it's empty).
  # 
  # @return [String]
  # 
  def to_s extended: nil
    # The way to get the superclass' message
    message = super()
    
    # If `extended` is explicitly `false` then just return that
    return message if extended == false
    
    # Otherwise, see if the extended message was explicitly requested,
    # of if we're configured to provide it as well.
    # 
    # Either way, don't add it it's empty.
    # 
    if  (extended || add_extended_message?) &&
        !extended_message.empty?
      message + "\n\n" + extended_message
    else
      message
    end
  end
  
end # module NRSER::NicerError
