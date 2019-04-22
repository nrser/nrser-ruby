# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ============================================================================

### Project / Package ###

require 'nrser/meta/args/array'


# Namespace
# =======================================================================

module  NRSER
module  Described
module  RSpec
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
def RESPONSE_TO *args, &body
  block = nil

  if args[ -1 ].is_a? Wrappers::Block
    block = args[ -1 ]
    args = args[ 0..-2 ]
  end
  
  DESCRIBE :response,
    args: Meta::Args::Array.new( *args, &block ),
    &body
end # #RESPONSE_TO


# New / bold name
alias_method :CALLED_WITH, :RESPONSE_TO


# Version of {#describe_called_with} for when you have no arguments.
# 
# @param [#call] body
#   Block to execute in the context of the example group after refining
#   the subject.
# 
# @return [void]
# 
def RESPONSE &body
  RESPONSE_TO &body
end


# new / bold name
alias_method :CALLED, :RESPONSE
  
  
# /Namespace
# =======================================================================

end # module Describe
end # module ExampleGroup
end # module RSpec
end # module Described
end # module NRSER
