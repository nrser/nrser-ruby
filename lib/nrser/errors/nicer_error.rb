# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

### Stdlib ###

# Using {PP.pp} as default dumper.
require 'pp'

### Deps ###

# Using {String#indent}
require 'active_support/core_ext/string/indent'

### Project / Package ###

# Using {NRSER::Text} to format messages
require 'nrser/text'

# Using {NRSER::Decorate::LazyAttr} to cache attribute values after first 
# computation
require 'nrser/decorate/lazy_attr'


# Namespace
# ========================================================================

module  NRSER


# Definitions
# =======================================================================

# A mixin for {Exception} and utilities to make life better... even when things
# go wrong.
#
# Check the docs at the {file:lib/nrser/errors/README.md nrser/errors README}.
# 
module NicerError
  
  # Constants
  # ========================================================================
  
  # Default column width
  DEFAULT_COLUMN_WIDTH = 78
  
  
  # Mixins
  # ============================================================================
  
  extend NRSER::Decorate
  

  # Modules
  # ============================================================================
  
  # Class methods added to modules that include {NicerError}.
  # 
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
    
    def text_renderer
      NicerError.text_renderer
    end
  end # module ClassMethods

  
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
  
  
  def self.text_renderer
    NRSER::Text.default_renderer
  end


  # Extend `base` with {ClassMethods}.
  # 
  # @param [Module] base
  #   Module including {NicerError}.
  # 
  # @return [void]
  # 
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
                  text_renderer: nil,
                  **context
    @binding = binding.freeze
    @context = context.freeze
    @details = details.freeze
    
    if text_renderer.is_a? NRSER::Text::Renderer
      @text_renderer = text_renderer
    end
    
    message = default_message if message.empty?
    super_message = format_message *message
    
    super super_message
  end # #initialize
  
  
  def text_renderer
    if instance_variable_defined? :@text_renderer
      @text_renderer
    else
      self.class.text_renderer
    end
  end
  
  
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
    Text.join *message
  end
  
  
  # Main message to use when none provided to {#initialize}.
  # 
  # @return [String]
  # 
  def default_message
    "(no message)"
  end


  def default_details
    nil
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
    @details || default_details
  end
  
  
  decorate NRSER::Decorate::LazyAttr,
  # Render details (first time only, then cached) and return the string.
  # 
  # @return [String?]
  # 
  def details_section
    # No details if we have nothing to work with
    if details.nil?
      nil
    else
      contents = case details
      when Proc
        details.call.to_s
      when String
        details
      else
        details.to_s
      end
      
      if contents.empty?
        nil
      else
        if @binding
          require 'nrser/ext/binding'
          contents = binding.n_x.erb contents
        end
        
        "# Details\n\n" + contents
      end
    end
  end # #details_section
  
  
  decorate NRSER::Decorate::LazyAttr,
  # @return [String?]
  # 
  def context_section
    if context.empty?
      nil
    else
      "# Context\n\n" + context.map { |name, value|
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
  end # #context_section
  
  
  # Return the extended message, rendering if necessary (cached after first
  # call).
  # 
  # @return [String]
  #   Will be empty if there is no extended message.
  # 
  def extended_message
    @extended_message ||= begin
      # builder = NRSER::Text.build renderer: text_renderer do
      #   section "Details" do
          
      #   end
      # end
      
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
  
  
  # Language Integration Instance Methods
  # --------------------------------------------------------------------------
  
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
    
    # We want to return just the super message if any of:
    # 
    # 1.  `extended` arg is explicitly `false` (an override of anything else).
    # 2.  `extended` is `nil` *and* {#add_extended_message?} is false.
    # 3.  {#extended_message?} is empty.
    # 
    if  extended == false ||
        (extended.nil? && !add_extended_message?) ||
        extended_message.empty?
      return message
    end
    
    message + "\n\n" + extended_message
  end
  
  
  # Language Integration Instance Methods
  # --------------------------------------------------------------------------
  
  def pretty_print pp
    pp.group(1, "{#{self.class}", "}") do
      pp.breakable ' '
      pp.seplist(
        [ [ 'message', to_s( extended: false ) ],
          ( context.empty? ? nil : [ 'context', context ] ),
        ].compact,
        nil
      ) do |(name, val)|
        pp.group do
          pp.text "#{ name }: "
          pp.group(1) do
            pp.breakable ''
            val.pretty_print(pp)
          end
        end
      end
    end
  end
  
end # module NicerError


# /Namespace
# ========================================================================

end # module NRSER
