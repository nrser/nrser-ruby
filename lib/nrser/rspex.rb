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
  if block
    Wrapper.new description: description, &block
  else
    Wrapper.new description: description.to_s do
      send description
    end
  end
end

def unwrap obj, context: nil
  if obj.is_a? Wrapper
    obj.unwrap context: context
  else
    obj
  end
end

def msg *args, &block
  NRSER::Message.from *args, &block
end


def List *args
  NRSER::RSpex::Format::List.new args
end

def Args *args
  NRSER::RSpex::Format::Args.new args
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

  
end # module NRSER:RSpex


RSpec.configure do |config|
  config.extend NRSER::RSpex::ExampleGroup
  config.include NRSER::RSpex::Example
  
  config.add_setting :x_type_prefixes
  config.x_type_prefixes = \
    NRSER::RSpex::PREFIXES
  
  config.add_setting :x_style, default: :esc_seq
end

# Make "describe" methods available at the top-level
include NRSER::RSpex::ExampleGroup::Describe
