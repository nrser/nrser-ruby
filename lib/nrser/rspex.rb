# encoding: utf-8

##############################################################################
# RSpec helpers, shared examples, extensions, and other goodies.
# 
# This file is *not* required by default when `nrser` is since it **defines
# global methods** and is not needed unless you're in [Rspec][].
# 
# [Rspec]: http://rspec.info/
# 
##############################################################################


# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------
require_relative './message'


# Helpers
# =====================================================================

# Merge "expectation" hashes by appending all clauses for each state.
# 
# @example
#   
# 
# @param [Array<Hash>] *expectations
#   Splat of "expectation" hashes - see the examples.
# 
def merge_expectations *expectations
  Hash.new { |result, state|
    result[state] = []
  }.tap { |result| 
    expectations.each { |ex|
      ex.each { |state, clauses|
        result[state] += clauses.to_a
      }
    }
  }
end

class Wrapper
  def initialize description: nil, &block
    @description = description
    @block = block
  end
  
  def unwrap context: nil
    if context
      context.instance_exec &@block
    else
      @block.call
    end
  end
  
  def to_s
    if @description
      @description.to_s
    else
      "#<Wrapper ?>"
    end
  end
end

def wrap description = nil, &block
  Wrapper.new description: description, &block
end

def unwrap obj, context: nil
  if obj.is_a? Wrapper
    obj.unwrap context: context
  else
    obj
  end
end

# Extensions
# =====================================================================

module NRSER; end

module NRSER::RSpex  
  
  # Constants
  # =====================================================================
  
  
  # Symbols
  # ---------------------------------------------------------------------
  # 
  # Sources:
  # 
  # -   https://en.wikipedia.org/wiki/Mathematical_operators_and_symbols_in_Unicode
  # 
  
  PREFIXES_BASE = {
    section: '§',
    group: '•',
  }
  
  PREFIXES_MATH_ITALIC = PREFIXES_BASE.merge(
    module:       '𝑀',
    method:       '𝑚',
    class:        '𝐶',
    attribute:    '𝑎',
    file:         '𝐹',
  )
  
  PREFIXES_MATH_CURSIVE_WORDS = PREFIXES_BASE.merge(
    module:       '𝓜 𝓸𝓭𝓾𝓵𝓮',
    method:       '𝓶𝓮𝓽',
    class:        '𝐶',
    attribute:    '𝑎',
    file:         '𝐹',
  )
  
  # PREFIXES_MATH_GREEK = PREFIXES_BASE.merge(
  #   # module: "𝓜 𝓸𝓭𝓾𝓵𝓮",
  #   module:       '𝛭',
  #   method:       '𝜆',
  #   class:        '𝛤',
  #   attribute:    '𝛼',
  # )
  
  PREFIXES = PREFIXES_MATH_ITALIC
  
  
  # Module (Class) Functions
  # =====================================================================
  
  
  # @todo Document short_s method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.short_s value
    NRSER.smart_ellipsis value.inspect, 64
  end # .short_s
  
  
  # Instance methods to extend example groups with.
  # 
  module ExampleGroup
    
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
    def describe_called_with *args, &block
      describe "called with #{ args.map( &NRSER::RSpex.method( :short_s ) ).join( ', ' ) }" do
        subject { super().call *args }
        instance_exec &block
      end
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
        instance_exec &body
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
        instance_exec &block
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
        instance_exec &body
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
        instance_exec &block
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
        instance_exec &body
      end
    end
    
    
    def describe_module mod, **metadata, &block
      describe(
        "#{ NRSER::RSpex::PREFIXES[:module] } #{ mod.name }",
        type: :module,
        **metadata
      ) do
        instance_exec &block
      end
    end # #describe_module
    
    
    def describe_class klass, **metadata, &block
      describe(
        "#{ NRSER::RSpex::PREFIXES[:class] } #{ klass.name }",
        type: :class,
        **metadata
      ) do
        instance_exec &block
      end
    end # #describe_class
    
    
    def describe_group title, **metadata, &block
      describe(
        "#{ NRSER::RSpex::PREFIXES[:group] } #{ title }",
        type: :group,
        **metadata
      ) do
        instance_exec &block
      end
    end # #describe_class
    
    
    def describe_method name, **metadata, &block
      describe(
        "#{ NRSER::RSpex::PREFIXES[:method] } #{ name }",
        type: :method,
        **metadata
      ) do
        instance_exec &block
      end
    end # #describe_method
    
    
    def describe_attribute symbol, **metadata, &block
      describe(
        "#{ NRSER::RSpex::PREFIXES[:attribute] } ##{ symbol }",
        type: :attribute,
        **metadata
      ) do
        subject { super().public_send symbol }
        instance_exec &block
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
          "#{ name } = #{ NRSER::RSpex.short_s value }"
        }.join( ', ' )
      end
      
      context "△ #{ description }", type: :where do
        bindings.each { |name, value|
          let( name ) { unwrap value, context: self }
        }
        
        instance_exec &body
      end
    end
    
    
  end # module ExampleGroup
  
end # module NRSER:RSpex

RSpec.configure do |config|
  config.extend NRSER::RSpex::ExampleGroup
end


include NRSER::RSpex::ExampleGroup


# Shared Examples
# =====================================================================

shared_examples "expect subject" do |*expectations|
  merge_expectations( *expectations ).each { |state, specs|
    specs.each { |verb, noun|
      it {
        # like: is_expected.to(include(noun))
        is_expected.send state, self.send(verb, noun)
      }
    }
  }
end # is expected


# Shared example for a functional method that compares input and output pairs.
# 
shared_examples "function" do |mapping: {}, raising: {}|
  mapping.each { |args, expected|
    args = NRSER.as_array args
    
    context "called with #{ args.map( &NRSER::RSpex.method( :short_s ) ).join ', ' }" do
      subject { super().call *args }
      
      it {
        expected = unwrap expected, context: self
        
        matcher = if expected.respond_to?( :matches? )
          expected
        elsif expected.is_a? NRSER::Message
          expected.send_to self
        else
          eq expected
        end
        
        is_expected.to matcher
      }
    end
  }
  
  raising.each { |args, error|
    args = NRSER.as_array args
    
    context "called with #{ args.map( &NRSER::RSpex.method( :short_s ) ).join ', ' }" do
    # it "rejects #{ args.map( &:inspect ).join ', ' }" do
      it { expect { subject.call *args }.to raise_error( *error ) }
    end
  }
end # function

