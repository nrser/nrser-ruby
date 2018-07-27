# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/errors/argument_error'
require 'nrser/props/immutable/hash'


# Refinements
# ========================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# ========================================================================

module  I8
module  Struct
  

# Definitions
# ========================================================================

# Base class for {I8::Hash}-based "propertied" ({NRSER::Props}) structs 
# created by {I8::Struct.new}.
# 
# @see I8::Struct
# @see NRSER::Props
# @see NRSER::Props::Immutable::Hash
# 
class Hash < I8::Hash

  include I8::Struct
  include NRSER::Props::Immutable::Hash

  # This method does two totally different things depending on what `self`
  # is:
  # 
  # 1.  If `self` is {I8::Struct::Hash}, we want to build a new struct class.
  #     
  # 2.  Otherwise, we want to defer up to `super` to create a new instance
  #     of `self`.
  # 
  # @overload self.new **prop_defs, &class_body
  #   When `self` **is** {I8::Struct::Hash}, the method builds a new 
  #   subclass, along the lines of how {I8::Struct.new} and `::Struct.new`
  #   work.
  #    
  #   @example
  #     Point = I8::Struct::Hash.new x: t.int, y: t.int
  #     # => Point
  #   
  #   @param [Hash<Symbol, (NRSER::Types::Type | Hash<Symbol, Object>)>] prop_defs
  #     Map of property names to the value(s) needed to create them.
  #     
  #     `prop_defs` values can each be:
  #     
  #     1.  {NRSER::Types::Type} - used as the {NRSER::Props::Prop#type}, with
  #         all the {NRSER::Props::Prop}'s other values left as defaults.
  #         
  #     2.  {Hash<Symbol, Object>} - full prop configuration, passed in to
  #         {NRSER::Props::Metadata#prop}.
  #   
  #   @param [Proc?] class_body
  #     Optional block to evaluate as the new class's body.
  #   
  #   @return [Class<I8::Struct::Hash>]
  #     New structure class.
  # 
  # @overload self.new *args, **kwds, &block
  #   When `self` **is not** {I8::Struct::Hash}, this method simply forwards
  #   all parameters up to it's super method, which will create a new 
  #   instance as usual.
  #   
  #   @example
  #     Point < I8::Struct::Hash
  #     # => true
  #     
  #     Point.new x: 1, y: 2 # Passes through to super method to construct
  #     # => Point[:y => 2, :x => 1]
  #   
  #   @return [I8::Struct::Hash]
  #     New instance.
  # 
  def self.new *args, **kwds, &block
    # Are we {I8::Struct::Hash}? (See method doc).
    if self == I8::Struct::Hash
      # Yes, we are. Time to build a new struct class.
      
      # Make sure we weren't given an positional `args`.
      unless args.empty?
        raise NRSER::ArgumentError.new \
          "Can not supply positional args when building new",
          "{I8::Struct::Hash}",
          args: args,
          kwds: kwds
      end

      # Create the new subclass
      Class.new( I8::Struct::Hash ) do
        kwds.each do |name, value|
          prop_kwds = t.match value,
            t.type, ->( type ) {{ type: type }},
            t.hash_, value
          
          prop name, **prop_kwds
        end
        
        class_exec &block if block
      end

    else
      # No, we are a built struct. Defer up to `super` to create an instance.
      
      # NOTE  Weirdness ahead. See NOTE in {I8::Struct::Vector.new}
      if kwds.empty?
        super( *args, &block )
      else
        super( *args, **kwds, &block )
      end

    end
  end # .new

end # class Hash


# /Namespace
# ========================================================================

end # module  Struct
end # module  I8

