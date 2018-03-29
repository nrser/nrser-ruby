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
  
  # HACK HACK HACK-ITY HACK - Allow for overriding RSpec methods
  # 
  # Yeah, it has to do with mixin mixing-in ordering - seems to be that when
  # 
  #     config.extend NRSER::RSpex::ExampleGroup
  # 
  # {NRSER::RSpex::ExampleGroup} gets mixed in *very early* in the chain,
  # before {RSpec::Core::ExampleGroup}... why you would provide an explicit
  # extension mechanism and not give those extensions priority I'm not sure,
  # but I'm sure I shouldn't be looking into it right now, so here we are:
  # 
  # It turns out that {NRSER::RSpex::Example}, which gets mixed with
  # 
  #     config.include NRSER::RSpex::Example
  # 
  # gets mixed *last*, so by using it's {NRSER::RSpex::Example.included}
  # hook we can use
  # 
  #   base#extend NRSER::RSpex::ExampleGroup::Overrides
  # 
  # to mix these guys over the top of RSpec's methods.
  # 
  # Seems like we could just mix all of {NRSER::RSpex::ExampleGroup} there
  # to get the behavior I would have expected all along, but maybe it's better
  # to have these explicit notes for the moment and not change much else until
  # I get the chance to really check out what's going on.
  # 
  # And really it's all to override `.described_class` to pick up our
  # metadata if it's there, but that approach is in quite a bit of use at
  # this point, and, no, I have no idea how it seemed to work up until this
  # point :/
  # 
  module Overrides
    
    # Override {RSpec::Core::ExampleGroup.described_class} to use RSpex's
    # `:class` metadata if it's present.
    # 
    # Because I can't figure out how to feed RSpec the described class
    # without it being the description, and we want better descriptions.
    # 
    # Some hackery could def do it, this is RUBY after all, but whatever this
    # works for now and may even be less fragile.
    # 
    # @return [Class]
    #   If there's a `:class` in the metadata, or if RSpec has on through the
    #   standard means (`describe MyClass do ...`).
    # 
    # @return [nil]
    #   If we don't have a class context around.
    # 
    def described_class
      metadata[:class] || super()
    end
    
  end
  
  
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

require_relative './example_group/describe_x'
require_relative './example_group/describe_spec_file'
require_relative './example_group/describe_when'
require_relative './example_group/describe_setup'
require_relative './example_group/describe_case'
require_relative './example_group/describe_instance'
require_relative './example_group/describe_instance_method'
require_relative './example_group/describe_called_with'
require_relative './example_group/describe_method'
require_relative './example_group/describe_class'
require_relative './example_group/describe_attribute'
require_relative './example_group/describe_module'
