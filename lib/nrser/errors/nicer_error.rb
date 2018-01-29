# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------


# Definitions
# =======================================================================

# A mixin for {Exception} and utilities to make errors nicer.
# 
module NRSER::NicerError
  
  
  # TODO document `context` attribute.
  # 
  # @return [Hash<Symbol, V>]
  #     
  attr_reader :context
  
  
  # @todo Document render_message method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.render_message message,
                          context: {},
                          add_context: true,
                          &get_extended_message
    
    # 1.  Figure out if `message` is just the "short message" (single line)
    #     or if it's "old-style" where it's just the whole thing.
    
    message_lines = message.lines
    
    if message_lines.length > 1
      message_lines = NRSER.dedent message_lines, return_lines: true
      short_message = message_lines.first.chomp
      extended_message_lines = message_lines.rest
    else
      short_message = message
      extended_message_lines = nil
    end
    
    # Ok, `short_message` is a single line string
    #     `extended_message_lines` is an array of string lines or `nil`
    
    # 2.
      
    if get_extended_message
      got_extended_message = if get_extended_message.arity == 0
        get_extended_message.call
      else
        get_extended_message.call context
      end
      
      got_extended_message_lines = NRSER.dedent \
        got_extended_message,
        return_lines: true
      
      if extended_message_lines
        extended_message_lines += [
          "\n",
          *got_extended_message_lines
        ]
      else
        extended_message_lines = got_extended_message_lines
      end
    end
    
    if add_context
      extended_message_lines += [
        "Context:\n",
        "\n"
        "\n    <%=  %>"
      ]
    end
      
  end # .render_message
  
  
  # @todo Document initialize method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def initialize  message,
                  context: {},
                  add_context: true,
                  &
    @context = context
  end # #initialize
  
end # module NRSER::NicerError
