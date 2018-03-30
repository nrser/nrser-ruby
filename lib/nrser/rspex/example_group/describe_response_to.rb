# encoding: UTF-8
# frozen_string_literal: true

module NRSER::RSpex::ExampleGroup
  
  # Describe the response of the subject to a {NRSER::Message}.
  # 
  # Pretty much a short-cut for nesting {#describe_method} /
  # {#describe_called_with}. Meh.
  # 
  # @param [Array] *args
  #   Passed to {NRSER::Message.from} to get or create the message instance.
  # 
  # @param &body          (see #describe_x)
  # 
  # @return (see #describe_x)
  # 
  def describe_response_to *args, &body
    msg = NRSER::Message.from *args
    
    # Pass up to {#describe_x}
    describe_x \
      msg,
      type: :response_to,
      subject_block: -> { msg.send_to super() },
      &body
  end # #describe_response_to
  
  # Old name
  alias_method :describe_return_value, :describe_response_to
  
end # module NRSER::RSpex::ExampleGroup
