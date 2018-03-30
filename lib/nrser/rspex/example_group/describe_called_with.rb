# encoding: UTF-8
# frozen_string_literal: true

module NRSER::RSpex::ExampleGroup
  
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
  # @param [Array] *args
  #   Arguments to call `subject` with to produce the new subject.
  # 
  # @param [#call] &block
  #   Block to execute in the context of the example group after refining
  #   the subject.
  # 
  # @return [void]
  # 
  def describe_called_with *args, &body
    describe_x Args(*args),
      type: :called_with,
      subject_block: -> { super().call *args },
      &body
  end # #describe_called_with
  
  # Short / old name
  alias_method :called_with, :describe_called_with
  
end # module NRSER::RSpex::ExampleGroup
