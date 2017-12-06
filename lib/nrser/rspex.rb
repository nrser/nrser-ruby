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
require 'nrser/message'
require 'nrser/rspex/shared_examples'


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


def List *args
  NRSER::RSpex::List.new args
end

def Args *args
  NRSER::RSpex::Args.new args
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
    invocation: '⟮⟯',
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
  def self.short_s value, max = 64
    NRSER.smart_ellipsis value.inspect, max
  end # .short_s
  
  
  
  # @todo Document format_type method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.format_type type, description
    prefixes = RSpec.configuration.x_type_prefixes
    
    return description if type.nil? || !prefixes.key?( type )
    
    "#{ prefixes[type] } #{ description }"
  end # .format_type
  
  
  
  # @todo Document format method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.format *parts, type: nil
    format_type \
      type,
      parts.
        map { |part|
          if part.respond_to? :to_desc
            part.to_desc
          elsif part.is_a? String
            part
          else
            short_s part
          end
        }.
        join( ' ' )
  end # .format
  
  
  class List < Array
    def to_desc max = nil
      return '' if empty?
      max = [16, 64 / self.length].max if max.nil?
      map { |entry| NRSER::RSpex.short_s entry, max }.join ", "
    end
  end
  
  
  class Opts < Hash
    def to_desc max = nil
      return '' if empty?
      
      max = [16, ( 64 / self.count )].max if max.nil?
      
      map { |key, value|
        if key.is_a? Symbol
          "#{ key }: #{ NRSER::RSpex.short_s value, max }"
        else
          "#{ NRSER::RSpex.short_s key, max } => #{ NRSER::RSpex.short_s value, max }"
        end
      }.join( ", " )
    end
  end
  
  
  class Args < Array
    def to_desc max = nil
      if last.is_a?( Hash )
        [
          List.new( self[0..-2] ).to_desc,
          Opts[ last ].to_desc,
        ].reject( &:empty? ).join( ", " )
      else
        super
      end
    end
  end
  
  
  # Instance methods to extend example groups with.
  # 
  module ExampleGroup
    
    
    # @todo Document describe_x method.
    # 
    # @param [type] arg_name
    #   @todo Add name param description.
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def describe_x_type *description_parts,
                        type:,
                        metadata: {},
                        subject_block: nil,
                        &body
      
      description = NRSER::RSpex.format *description_parts, type: type
      
      describe description, **metadata, type: type do
        subject( &subject_block ) if subject_block
        instance_exec &body
      end # description, 
      
    end # #describe_x
    
    
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
        
        instance_exec &block
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
        instance_exec &block
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
          "#{ name }: #{ NRSER::RSpex.short_s value }"
        }.join( ", " )
      end
      
      context "△ #{ description }", type: :where do
        bindings.each { |name, value|
          let( name ) { unwrap value, context: self }
        }
        
        instance_exec &body
      end
    end
    
    
  end # module ExampleGroup
  
  
  # Extensions available in examples themselves via RSpec's `config.include`.
  # 
  module Example
    def described_class
      self.class.metadata[:class] || super
    end
    
    def described_constructor_args
      self.class.metadata[:constructor_args]
    end
    
  end
  
end # module NRSER:RSpex


RSpec.configure do |config|
  config.extend NRSER::RSpex::ExampleGroup
  config.include NRSER::RSpex::Example
  
  config.add_setting :x_type_prefixes
  config.x_type_prefixes = \
    NRSER::RSpex::PREFIXES_BASE.merge( NRSER::RSpex::PREFIXES_MATH_ITALIC )
end

# Make available at the top-level
include NRSER::RSpex::ExampleGroup

