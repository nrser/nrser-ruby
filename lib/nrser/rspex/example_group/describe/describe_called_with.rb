# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# =======================================================================

module  NRSER
module  RSpex
module  ExampleGroup
module  Describe


# Definitions
# ========================================================================

# Create a new {RSpec.describe} section where the subject is set by
# calling the parent subject with `args` and evaluate `block` in it.
# 
# @example
#   describe "hi sayer" do
#     subject{ ->( name ) { "Hi #{ name }!" } }
#     
#     describe_called_with 'Mom' do
#       it { is_expected.to eq 'Hi Mom!' }
#     end
#   end
# 
# @param [Array] args
#   Arguments to call `subject` with to produce the new subject.
# 
# @param [#call] body
#   Block to execute in the context of the example group after refining
#   the subject.
# 
# @return [void]
# 
def describe_called_with *args, &body
  args = RSpex::Format::Args.new args
  
  describe_x Args(*args),
    type: :called_with,
    metadata: {
      called_with_args: args,
    },
    subject_block: -> { super().call *args },
    &body
end # #describe_called_with


# New / bold name
alias_method :CALLED_WITH, :describe_called_with


# Version of {#describe_called_with} for when you have no arguments.
# 
# @param [#call] body
#   Block to execute in the context of the example group after refining
#   the subject.
# 
# @return [void]
# 
def describe_called &body
  describe_x Args(),
    type: :called_with,
    metadata: {
      called_with_args: RSpex::Format::Args.new,
    },
    subject_block: -> { super().call },
    &body
end


# new / bold name
alias_method :CALLED, :describe_called
  
  
# /Namespace
# =======================================================================

end # module Describe
end # module ExampleGroup
end # module RSpex
end # module NRSER
