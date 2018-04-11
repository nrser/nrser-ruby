# encoding: UTF-8
# frozen_string_literal: true

require 'pp'


# Definitions
# =======================================================================

# A mixin for {Exception} and utilities to make errors nicer.
# 
module NRSER::NicerError
  
  # Constants
  # ========================================================================
  
  DEFAULT_FORMAT_WIDTH = 78
  
  
  # Module Methods
  # ==========================================================================
  
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
  def self.format_message_segment segment
    return segment if String === segment
    
    # TODO  Do better!
    segment.inspect
  end # .format_message_segment
  
  
  def self.format_width
    DEFAULT_FORMAT_WIDTH
  end
  
  
  # Construct a nicer error.
  # 
  # @param [Array] *message
  #   Main message segments.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def initialize  *message,
                  binding: nil,
                  details: nil,
                  **context
    
    super_message = case message.length
    when 0
      "(no message)"
    when 1
      message[0]
    else
      message.
        map( &NRSER::NicerError.method( :format_message_segment ) ).
        join ' '
    end
    
    @binding = binding
    @context = context
    @details = details
    
    super super_message
  end # #initialize
  
  
  # Any additional context values to add to extended messages provided to
  # {#initialize}.
  # 
  # @return [Hash<Symbol, *>]
  # 
  def context
    @context
  end
  
  
  # Render details (first time, then cached) and return the string.
  # 
  # @return [String?]
  # 
  def details_section
    @details_section ||= begin
      # No details if we have nothing to work with
      if @details.nil?
        nil
      else
        contents = case @details
        when Proc
          if @binding.nil?
            @details.call
          else
            @binding.erb @details.call
          end
        when String
          @details
        else
          @details.to_s
        end
        
        if contents.empty?
          nil
        else
          "# Details\n\n" + contents
        end
      end
    end
  end
  
  
  # @return [String?]
  # 
  def context_section
    @context_section ||= begin
      if context.empty?
        nil
      else
        "# Context:\n\n" + context.map { |name, value|
          name_str = name.to_s
          value_str = PP.pp \
            value,
            ''.dup,
            (NRSER::NicerError.format_width - name_str.length - 2)
          
          if value_str.lines.count > 1
            "#{ name_str }:\n\n#{ value_str.indent 4 }\n"
          else
            "#{ name_str }: #{ value_str }\n"
          end
        }.join
      end
    end
  end
  
  
  def extended_message
    @extended_message ||= begin
      sections = []
      
      sections << details_section unless details_section.nil?
      sections << context_section unless context_section.nil?
      
      joined = sections.join "\n\n"
    end
  end
  
  
  def to_s
    message = super
    
    if true && !extended_message.empty?
      message + "\n\n" + extended_message
    else
      message
    end
  end
  
  
  def raise_
    raise self
  end
  
end # module NRSER::NicerError
