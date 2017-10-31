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
    def when_called_with *args, &block
      context "called with #{ args.map( &:inspect ).join( ', ' ) }" do
        subject { super().call *args }
        instance_exec &block
      end
    end # #called_with
    
    alias_method :called_with, :when_called_with
    
    
    def describe_message symbol, *args, &body
      description = \
        "message #{ [symbol, *args].map( &:inspect ).join( ', ' ) }"
      
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
    def when_sent_to receiver, publicly: true, &block
      mode = if publicly
        "publicly"
      else
        "privately"
      end
      
      context "sent to #{ receiver } (#{ mode })" do
        subject { super().send_to receiver  }
        instance_exec &block
      end
    end # #when_sent_to
    
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
        elsif expected.is_a? NRSER::Message
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

