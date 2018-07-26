# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------
require 'set'

# Deps
# -----------------------------------------------------------------------
require 'hamster'

# Project / Package
# -----------------------------------------------------------------------
require 'nrser/errors/type_error'
require 'nrser/props/immutable/hash'
require 'nrser/props/immutable/vector'

require 'nrser/refinements/types'
using NRSER::Types


# Definitions
# =======================================================================

class Object
  def if proc_able, &block
    block.call( self ) if proc_able.to_proc.call( self )
  end

  def unless proc_able, &block
    block.call( self ) unless proc_able.to_proc.call( self )
  end
end


# Sick of typing "Hamster::Hash"...
# 
# Experimental Hamster sugary sweet builder shortcut things.
# 
module I8
  
  # Easy way to get the class names shorter..?
  class Vector < Hamster::Vector; end
  class Hash < Hamster::Hash; end

  class Set < Hamster::Set

    # Get a {I8::Set} containing `items`.
    #
    # Overridden to...
    #
    # 1.  Return `items` if items is already a {I8::Set}... sort of like a copy
    #     constructor that doesn't actually copy because the instances are
    #     immutable.
    #
    # 2.  Return an instance of `self` pointing to `items`'s {Hamster::Trie}
    #     if `items` is a {Hamster::Set}; this way you get an instance of
    #     the correct class but don't do any additional instantiation.
    # 
    # 3.  Returns {.empty} if `items` responds to `#empty?` truthfully.
    # 
    # Otherwise, defers to `super`.
    # 
    # @param [#each] items
    #   Items for the new set to contain.
    # 
    # @return [I8::Set]
    #
    def self.new items = []
      case items
      when self
        items
      when Hamster::Set
        alloc items.instance_variable_get( :@trie )
      else
        if items.respond_to?( :empty? ) && items.empty?
          self.empty
        else
          super items
        end
      end
    end

    # Override to build our empty set through {.alloc} so that we can return
    # it in {.new}.
    # 
    # @return [I8::Set]
    # 
    def self.empty
      @empty ||= alloc Hamster::Trie.new( 0 )
    end

  end # class Set

  class SortedSet < Hamster::SortedSet; end
  # class List < Hamster::List; end # Not a class! Ugh...
  
  
  module Struct
    
    def self.check_new_args! vector_prop_defs, hash_prop_defs
      
      unless  (vector_prop_defs.empty? && !hash_prop_defs.empty?) ||
              (!vector_prop_defs.empty? && hash_prop_defs.empty?)
        
        raise NRSER::ArgumentError.new \
          "Exactly one of *args or **kwds must be empty",
          
          args: vector_prop_defs,
          
          kwds: hash_prop_defs,
          
          details: -> {%{
            {I8::Struct.define} proxies to either
            
            1.  {I8::Struct::Vector.define}
            2.  {I8::Struct::Hash.define}
            
            depending on *where* the property definitions are passed:
            
            1.  Positionally in `*args` -> {I8::Struct::Vector.new}
            2.  By name in `**kwds` -> {I8::Struct::Hash.new}
            
            Examples:
            
            1.  Create a Point struct backed by an {I8::Vector}:
                
                    Point = I8::Struct.define [x: t.int], [y: t.int]
                
            2.  Create a Point struct backed by an {I8::Hash}:
                
                    Point = I8::Struct.define x: t.int, y: t.int
            
          }}
        
      end # unless vector_prop_defs.empty? XOR hash_prop_defs.empty?
      
    end # .check_new_args!
    
    private_class_method :check_new_args!
    
    
    def self.define *vector_prop_defs, **hash_prop_defs, &body
      check_new_args! vector_prop_defs, hash_prop_defs
      
      if !vector_prop_defs.empty?
        raise "not implemented"
        # I8::Struct::Vector.new
      else
        I8::Struct::Hash.new **hash_prop_defs, &body
      end
    end
    
    singleton_class.send :alias_method, :new, :define
    
    
  end # module Struct
  
  
  class Struct::Hash < I8::Hash
    include I8::Struct
    include NRSER::Props::Immutable::Hash
    
    def self.define **prop_defs, &body
      Class.new( I8::Struct::Hash ) do
        prop_defs.each do |name, settings|
          kwds = t.match settings,
            t.type, ->( type ) {{ type: type }},
            t.hash_, settings
          
          prop name, **kwds
        end
        
        class_exec &body if body
      end
    end
    
    def self.new *args, **kwds, &block
      if self == I8::Struct::Hash
        define *args, **kwds, &block
      else
        # See NOTE in {I8::Struct::Vector.new}
        if kwds.empty?
          super( *args, &block )
        else
          super( *args, **kwds, &block )
        end
      end
    end
  end
  
  
  class Struct::Vector < I8::Vector
    include I8::Struct
    include NRSER::Props::Immutable::Vector
    
    def self.define *prop_defs, &body
      # Unwrap `[name: type]` format
      prop_defs.map! { |prop_def|
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
          name, settings = pair.first
          
          kwds = t.match settings,
            t.type, ->( type ) {{ type: type }},
            t.hash_, settings
          
          prop name, **kwds, index: index
        end
        
        class_exec &body if body
      end
    end
    
    
    def self.new *args, **kwds, &block
      if self == I8::Struct::Vector
        unless kwds.empty?
          raise NRSER::ArgumentError.new \
            "Can not supply keyword args",
            args: args,
            kwds: kwds
        end
    
        define *args, &block
      else
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
    end
    
  end # class Struct::Vector
  
  
  def self.[] value
    case value
    when  Hamster::Hash,
          Hamster::Vector,
          Hamster::Set,
          Hamster::SortedSet,
          Hamster::List
      value
    when ::Hash
      I8::Hash[value]
    when ::Array
      I8::Vector.new value
    when ::Set
      I8::Set.new value
    when ::SortedSet
      I8::SortedSet.new value
    else
      raise NRSER::TypeError.new \
        "Value must be Hash, Array, Set or SortedSet",
        found: value
    end
  end # .[]
  
end # module I8


# Method proxy to {I8.[]} allowing for different syntaxes.
# 
def I8 value = nil
  I8[ value || yield ]
end
