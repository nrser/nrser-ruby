##############################################################################
# RSpec helpers, shared examples, extensions, and other goodies.
# 
# This file is *not* required by default when `nrser` is since it **defines
# global methods** and is not needed unless you're in [Rspec][].
# 
# [Rspec]: http://rspec.info/
# 
##############################################################################


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

class Msg
  
  # Name of method the message is for.
  # 
  # @return [Symbol | String]
  #     
  attr_reader :symbol
  
  
  # Arguments 
  # 
  # @return [Array]
  #     
  attr_reader :args
  
  
  # TODO document `block` attribute.
  # 
  # @return [#call]
  #     
  attr_reader :block
  
  
  def initialize symbol, *args, &block
    @symbol = symbol
    @args = args
    @block = block
  end
  
  
  def to_a
    [symbol, *args]
  end
  
  
  def to_proc
    block
  end
  
end


# Extensions
# =====================================================================

module NRSER; end

module NRSER::RSpex
  
  # Instance methods to extend example groups with.
  # 
  module ExampleGroup
    
    # Call the current subject with `args` to produce a new subject for
    # `block`.
    # 
    # @param [Array] *args
    #   Arguments to call `subject` with to produce the new subject.
    # 
    # @param [#call] &block
    #   Block to execute in the context of the example group after refining
    #   the subject.
    # 
    def called_with *args, &block
      context "called with #{ args.map( &:inspect ).join( ', ' ) }" do
        subject { super().call *args }
        instance_exec &block
      end
    end # #called_with
    
    alias_method :when_called_with, :called_with
    
  end # module ExampleGroup
  
end # module NRSER:RSpex

RSpec.configure do |config|
  config.extend NRSER::RSpex::ExampleGroup
end


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
    
    context "called with #{ args.map( &:inspect ).join ', ' }" do
      subject { super().call *args }
      
      it {
        matcher = if expected.respond_to?( :matches? )
          expected
        elsif expected.is_a? Msg
          self.send *expected #, &expected
        else
          eq expected
        end
        
        is_expected.to matcher
      }
    end
  }
  
  raising.each { |args, error|
    args = NRSER.as_array args
    
    context "called with #{ args.map( &:inspect ).join ', ' }" do
    # it "rejects #{ args.map( &:inspect ).join ', ' }" do
      it { expect { subject.call *args }.to raise_error( *error ) }
    end
  }
end # function

