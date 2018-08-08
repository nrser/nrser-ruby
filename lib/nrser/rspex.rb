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
require 'rspec'
require 'commonmarker'

# Project / Package
# -----------------------------------------------------------------------
require 'nrser'
require 'nrser/core_ext'

require_relative './rspex/example'
require_relative './rspex/example_group'
require_relative './rspex/shared_examples'
require_relative './rspex/format'


# Refinements
# =======================================================================

using NRSER


# Helpers
# =====================================================================

# Merge "expectation" hashes by appending all clauses for each state.
# 
# @param [Array<Hash>] expectations
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
    case description
    when Symbol
      @description = description.to_s
      
      if block
        raise ArgumentError,
          "Don't provide block with symbol"
      end
      
      if @description.start_with? '@'
        @block = Proc.new { instance_variable_get description }
      else
        @block = description.to_proc
      end
    else
      @description = description
      @block = block
    end
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
  
  def inspect
    to_s
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

module NRSER::RSpex
  
  # Constants
  # =====================================================================
  
  # Symbol characters for specific example group types.
  # 
  # Sources:
  # 
  # -   https://en.wikipedia.org/wiki/Mathematical_operators_and_symbols_in_Unicode
  # 
  PREFIXES = {
    section: '§',
    group: '•',
    invocation: '𝑓⟮𝑥⟯',
  }
  
  
  # Module (Class) Functions
  # =====================================================================
  
  
  def self.short_s value, max = 64
    NRSER.smart_ellipsis value.inspect, max
  end # .short_s
  
  
  def self.format *args
    NRSER::RSpex::Format.description *args
  end # .format
  
  
  # Get the relative path from the working directory with the `./` in front.
  # 
  # @param [String | Pathname] dest
  #   Destination file path.
  # 
  # @return [String]
  # 
  def self.dot_rel_path dest
    File.join '.', dest.to_pn.relative_path_from( Pathname.getwd )
  end # .dot_rel_path
  
  
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
  
  
  class Args < List
    def to_desc max = nil
      return '()' if empty?
      
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
  
end # module NRSER:RSpex


RSpec.configure do |config|
  config.extend NRSER::RSpex::ExampleGroup
  config.include NRSER::RSpex::Example
  
  config.add_setting :x_type_prefixes
  config.x_type_prefixes = \
    NRSER::RSpex::PREFIXES
  
  config.add_setting :x_style, default: :esc_seq
end

# Make available at the top-level
include NRSER::RSpex::ExampleGroup
