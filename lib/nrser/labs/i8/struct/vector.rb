# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/errors/argument_error'
require 'nrser/props/immutable/vector'


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

# Base class for {I8::Vector}-based "propertied" ({NRSER::Props}) structs 
# created by {I8::Struct.new}.
# 
# @see I8::Struct
# @see NRSER::Props
# @see NRSER::Props::Immutable::Vector
# 
class Vector < I8::Vector
  include I8::Struct
  include NRSER::Props::Immutable::Vector
  
  # Check out {I8::Struct::Hash} for a general idea of how this method works,
  # I don't want to duplicate the explanation.
  # 
  # @overload self.new *prop_defs, &class_body
  #   Create a new struct class.
  #   
  #   @example Using array-wrapping for prop defs
  #     Point = I8::Struct::Vector.new [x: t.int], [y: t.int]
  #     # => Point
  # 
  #   @example Using hashes for prop defs
  #     Point = I8::Struct::Vector.new( {x: t.int}, {y: t.int} )
  #     # => Point
  # 
  # @example Providing additional prop options
  #     Point = I8::Struct::Vector.new \
  #       [x: {type: t.int, default: 0}],
  #       [y: {type: t.int, default: 0}]
  #     # => Point
  #   
  #   @param [Array] prop_defs
  #     Each entry must be a pair; the first entry must be the name as a
  #     symbol, the second is either the prop's type or a hash of options
  #     for creating the prop.
  #     
  #     Look at the examples.
  #   
  #   @param [Proc?] class_body
  #     Optional block to evaluate as the new class's body.
  #   
  #   @return [Class<I8::Struct::Vector>]
  #     New structure class.
  # 
  # @overload self.new *args, **kwds, &block
  #   Create a new instance.
  #   
  #   @return [I8::Struct::Vector]
  #     New instance.
  # 
  def self.new *args, **kwds, &block
    # Are we {I8::Struct::Vector}? (See method doc).
    if self == I8::Struct::Vector
      unless kwds.empty?
        raise NRSER::ArgumentError.new \
          "Can not supply keyword args",
          args: args,
          kwds: kwds
      end
  
      # Unwrap `[name: type]` format
      prop_defs = args.map { |prop_def|
        if  ::Array === prop_def &&
            prop_def.length == 1 &&
            ::Hash === prop_def[0]
          prop_def[0]
        else
          prop_def
        end
      }
      
      # Check we have a list of pairs with label keys
      t.array( t.pair( key: t.label ) ).check! prop_defs
      
      Class.new( I8::Struct::Vector ) do
        prop_defs.each_with_index do |pair, index|
          name, value = pair.first
          
          kwds = t.match value,
            t.type, ->( type ) {{ type: type }},
            t.hash_, value
          
          prop name, **kwds, index: index
        end
        
        class_exec &block if block
      end

    else
      # No, we are a built struct. Defer up to `super` to create an instance.

      # NOTE  This is... weird. Just doing the normal
      #       
      #           super( *args, **kwds, &block )
      #       
      #       results in `*args` becoming `[*args, {}]` up the super chain
      #       when `kwds` is empty.
      #       
      #       I can't say I can understand it, but I seem to be able to fix
      #       it.
      # 
      if kwds.empty?
        super( *args, &block )
      else
        super( *args, **kwds, &block )
      end

    end
  end # .new
  
end # class Struct::Vector


# /Namespace
# ========================================================================

end # module  Struct
end # module  I8

