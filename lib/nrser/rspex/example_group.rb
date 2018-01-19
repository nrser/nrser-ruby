# frozen_string_literal: true
# encoding: utf-8

# Instance methods to extend examples groups with. Also included globally so
# they're available at the top-level in files.
# 
module NRSER::RSpex::ExampleGroup
  
  # @todo Document describe_instance method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def describe_instance *constructor_args, &body
    describe_x_type ".new(", Args(*constructor_args), ")",
      type: :instance,
      metadata: {
        constructor_args: constructor_args,
      },
      # subject_block: -> { super().new *described_args },
      subject_block: -> { super().new *described_constructor_args },
      &body
  end # #describe_instance
  
  
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
  def describe_called_with *args, &body
    describe_x_type  "called with", List(*args),
      type: :invocation,
      subject_block: -> { super().call *args },
      &body
  end # #describe_called_with
  
  # Aliases to other names I was using at first... not preferring their use
  # at the moment.
  # 
  # The `when_` one sucks because Atom de-dents the line, and `describe_`
  # is just clearer what the block is doing for people reading it.
  alias_method :called_with, :describe_called_with
  alias_method :when_called_with, :describe_called_with
  
  
  def describe_message symbol, *args, &body
    description = \
      "message #{ [symbol, *args].map( &NRSER::RSpex.method( :short_s ) ).join( ', ' ) }"
    
    describe description, type: :message do
      subject { NRSER::Message.new symbol, *args }
      module_exec &body
    end
  end
  
  
  # For use when `subject` is a {NRSER::Message}. Create a new context for
  # the `receiver` where the subject is the result of sending that message
  # to the receiver.
  # 
  # @param [Object] receiver
  #   Object that will receive the message to create the new subject.
  # 
  # @param [Boolean] publicly:
  #   Send message publicly via {Object#public_send} (default) or privately
  #   via {Object.send}.
  # 
  # @return
  #   Whatever the `context` call returns.
  # 
  def describe_sent_to receiver, publicly: true, &block
    mode = if publicly
      "publicly"
    else
      "privately"
    end
    
    describe "sent to #{ receiver } (#{ mode })" do
      subject { super().send_to unwrap( receiver, context: self ) }
      module_exec &block
    end
  end # #describe_sent_to
  
  # Aliases to other names I was using at first... not preferring their use
  # at the moment.
  # 
  # The `when_` one sucks because Atom de-dents the line, and `describe_`
  # is just clearer what the block is doing for people reading it.
  alias_method :sent_to, :describe_sent_to
  alias_method :when_sent_to, :describe_sent_to
  
  
  def describe_return_value *args, &body
    msg = NRSER::Message.from *args
    
    describe "return value from #{ msg }" do
      subject { msg.send_to super() }
      module_exec &body
    end # "return value from #{ msg }"
  end
  
  
  # Describe a "section". Just like {RSpec.describe} except it:
  # 
  # 1.  Expects a string title.
  #     
  # 2.  Prepends a little section squiggle `§` to the title so sections are
  #     easier to pick out visually.
  #     
  # 3.  Adds `type: :section` metadata.
  # 
  # @param [String] title
  #   String title for the section.
  # 
  # @param [Hash<Symbol, Object>] **metadata
  #   Additional [RSpec metadata][] for the example group.
  #   
  #   [RSpec metadata]: https://relishapp.com/rspec/rspec-core/docs/metadata/user-defined-metadata
  # 
  # @return
  #   Whatever {RSpec.describe} returns.
  # 
  def describe_section title, **metadata, &block
    describe(
      "#{ NRSER::RSpex::PREFIXES[:section] } #{ title }",
      type: :section,
      **metadata
    ) do
      module_exec &block
    end
  end # #describe_section
  
  # Old name
  alias_method :describe_topic, :describe_section
  
  
  def describe_file path, **metadata, &body
    title = path
    
    describe(
      "#{ NRSER::RSpex::PREFIXES[:file] } #{ title }",
      type: :file,
      file: path,
      **metadata
    ) do
      module_exec &body
    end
  end
  
  
  def describe_module mod, bind_subject: true, **metadata, &block
    describe(
      "#{ NRSER::RSpex::PREFIXES[:module] } #{ mod.name }",
      type: :module,
      module: mod,
      **metadata
    ) do
      if bind_subject
        subject { mod }
      end
      
      module_exec &block
    end
  end # #describe_module
  
  
  def describe_class klass, bind_subject: true, **metadata, &block
    description = "#{ NRSER::RSpex::PREFIXES[:class] } #{ klass.name }"
    
    describe(
      description,
      type: :class,
      class: klass,
      **metadata
    ) do
      if bind_subject
        subject { klass }
      end
      
      module_exec &block
    end
  end # #describe_class
  
  
  def described_class
    metadata[:class] || super()
  end
  
  
  def describe_group title, **metadata, &block
    describe(
      "#{ NRSER::RSpex::PREFIXES[:group] } #{ title }",
      type: :group,
      **metadata
    ) do
      module_exec &block
    end
  end # #describe_class
  
  
  def describe_method name, **metadata, &block
    describe(
      "#{ NRSER::RSpex::PREFIXES[:method] } #{ name }",
      type: :method,
      method_name: name,
      **metadata
    ) do
      if name.is_a? Symbol
        subject { super().method name }
      end
      
      module_exec &block
    end
  end # #describe_method
  
  
  def describe_attribute symbol, **metadata, &block
    describe(
      "#{ NRSER::RSpex::PREFIXES[:attribute] } ##{ symbol }",
      type: :attribute,
      **metadata
    ) do
      subject { super().public_send symbol }
      module_exec &block
    end
  end # #describe_attribute
  
  # Shorter name
  alias_method :describe_attr, :describe_attribute
  
  
  # Define a `context` block with `let` bindings and evaluate the `body`
  # block in it.
  # 
  # @param [Hash<Symbol, Object>] **bindings
  #   Map of symbol names to value to bind using `let`.
  # 
  # @param [#call] &body
  #   Body block to evaluate in the context.
  # 
  # @return
  #   Whatever `context` returns.
  # 
  def context_where description = nil, **bindings, &body
    
    if description.nil?
      description = bindings.map { |name, value|
        "#{ name }: #{ NRSER::RSpex.short_s value }"
      }.join( ", " )
    end
    
    context "△ #{ description }", type: :where do
      bindings.each { |name, value|
        let( name ) { unwrap value, context: self }
      }
      
      module_exec &body
    end
  end
  
end # module NRSER:RSpex::ExampleGroup


# Post-Processing
# =======================================================================

require_relative './example_group/describe_x'
require_relative './example_group/describe_spec_file'
require_relative './example_group/describe_when'
require_relative './example_group/describe_setup'
require_relative './example_group/describe_use_case'
