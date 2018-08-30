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
# Check the docs at the {file:lib/nrser/errors/README.md nrser/errors README}.
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


  module ClassMethods
    def def_context_delegator keys:, presence_predicate: true
      keys = Array keys

      keys.each do |key|
        define_method key do
          if (found_key = keys.find { |k| context.key? k })
            context[found_key]
          end
        end

        if presence_predicate
          define_method "#{ key }?" do
            !!keys.find { |k| context.key? k }
          end
        end
      end
    end
  end

  def self.included base
    base.extend ClassMethods
  end
  
  
  # Construct a nicer error.
  # 
  # @param [Array] message
  #   Main message segments. See {#format_message} and {#format_message_segment}
  #   for an understanding of how they are, well, formatted.
  # 
  # @param [Binding?] binding
  #   When provided any details string will be rendered using it's
  #   {Binding#erb} method.
  # 
  # @param [nil | String | Proc<()=>String> | #to_s] details
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
  # @param [Hash<Symbol, VALUE>] context
  #   Any additional names and values to dump with an extended message.
  # 
  def initialize  *message,
                  binding: nil,
                  details: nil,
                  **context
    @binding = binding.freeze
    @context = context.freeze
    @details = details.freeze
    
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
  # @todo
  #   This should talk to config when that comes about to find out how to
  #   dump things.
  # 
  def format_message_segment segment
    return segment.to_summary if segment.respond_to?( :to_summary )
    
    return segment if String === segment
    
    # TODO  Do better!
    segment.inspect
  end # #format_message_segment
  
  
  # Format the main message by converting args to strings and joining them.
  # 
  # @param [Array] message
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
  # @param [Boolean?] extended
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
