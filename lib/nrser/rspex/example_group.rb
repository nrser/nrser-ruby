# frozen_string_literal: true
# encoding: utf-8


# Declarations
# =======================================================================

module NRSER::RSpex; end


# Definitions
# =======================================================================

# Instance methods to extend examples groups with. Also included globally so
# they're available at the top-level in files.
# 
module NRSER::RSpex::ExampleGroup
  
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
  
  
  def describe_group title, **metadata, &block
    describe(
      "#{ NRSER::RSpex::PREFIXES[:group] } #{ title }",
      type: :group,
      **metadata
    ) do
      module_exec &block
    end
  end # #describe_class
  
  
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

require_relative './example_group/overrides'

require_relative './example_group/describe_attribute'
require_relative './example_group/describe_called_with'
require_relative './example_group/describe_case'
require_relative './example_group/describe_class'
require_relative './example_group/describe_instance_method'
require_relative './example_group/describe_instance'
require_relative './example_group/describe_message'
require_relative './example_group/describe_method'
require_relative './example_group/describe_module'
require_relative './example_group/describe_setup'
require_relative './example_group/describe_source_file'
require_relative './example_group/describe_spec_file'
require_relative './example_group/describe_when'
require_relative './example_group/describe_x'
