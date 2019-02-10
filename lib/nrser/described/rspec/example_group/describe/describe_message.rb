# encoding: UTF-8
# frozen_string_literal: true

# Namespace
# =======================================================================

module  NRSER
module  RSpec
module  ExampleGroup
module  Describe


# Definitions
# ========================================================================

# Describe a {NRSER::Message}. Useful when you have a message that you want
# to send to many receivers (see {#describe_sent_to}).
# 
# @note
#   Since the block is used for the example group body, if you want to
#   describe a message with a {NRSER::Message#block} your need to create
#   the message yourself and pass it as the only argument.
# 
# @see #describe_x
#
# @param [Array] args
#   Passed to {NRSER::Message.from} to get or create the message instance.
# 
# @param &body (see #describe_x)
# 
# @return (see #describe_x)
# 
def describe_message *args, &body
  message = NRSER::Message.from *args
  
  describe_x \
    message,
    type: :message,
    metadata: {
      message: message,
    },
    subject_block: -> { message.send_to super() },
    &body
end

alias_method :MESSAGE, :describe_message


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpec
end # module NRSER
