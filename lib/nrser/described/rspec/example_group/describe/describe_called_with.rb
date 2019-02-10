# encoding: UTF-8
# frozen_string_literal: true


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
def describe_called_with *args, **kwds, &body
  params = Meta::Params.new args: args, kwds: kwds
  DESCRIBE :response, params: params, &body
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
  describe_called_with &body
end


# new / bold name
alias_method :CALLED, :describe_called
  
  
# /Namespace
# =======================================================================

end # module Describe
end # module ExampleGroup
end # module RSpec
end # module Described
end # module NRSER
