# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------
require 'nrser/errors/argument_error'
require 'nrser/labs/i8'

require_relative './struct/hash'
require_relative './struct/vector'


# Refinements
# ========================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# ========================================================================

module  I8
  

# Definitions
# ========================================================================

# `I8::Struct` is an immutable rendition of the Ruby standard lib `::Struct`
# using the {NRSER::Props} system.
# 
# It's intended to help make it quick and easy to create little immutable
# propertied objects, with all the type-checking and serialization stuff
# that comes with {NRSER::Props}.
# 
# `Struct` itself is a module with a {.new} method that creates new subclasses
# of either {I8::Struct::Hash} or {I8::Struct::Vector}, which themselves 
# are respective subclasses of {I8::Hash} and {I8::Vector}, and include
# {NRSER::Props::Immutable::Hash} and {NRSER::Props::Immutable::Vector}.
# 
# ### Identifying Classes Built by `I8::Struct` 
# 
# Both {I8::Struct::Hash} and {I8::Struct::Vector} also include `I8::Struct`
# itself for the convenience of shit like:
# 
#     Point = I8::Struct.new x: t.int, y: t.int
#     
#     Point.included_modules.include? I8::Struct
#     #  => true
#     
#     p = Point.new x: 1, y: 2
#     p.is_a? I8::Struct
#     # => true
# 
# `I8::Struct` has only class (static) methods, so no functionality is 
# actually added from `include I8::Struct`.
# 
# ### Gotchas
# 
# The code below *doesn't* work how you might want or expect it:
# 
#     Point = I8::Struct.new x: t.int, y: t.int
#     Point.is_a? I8::Struct
#     # => false
# 
# Opposed to how {Class} works:
# 
#     C = Class.new
#     C.is_a? Class
#     # => true
# 
# However, this *is* the same as how the stdlib's [::Struct][] behaves:
# 
#     S = ::Struct.new :x
#     S.is_a? ::Struct
#     # => false
# 
# [::Struct]: https://ruby-doc.org/core/Struct.html
# 
# @example One-Liner
#   Person = I8::Struct.new name: t.non_empty_str, age: t.non_neg_int
#   nrser = Person.new name: "Neil", age: 34
# 
# @example Extend a `I8::Struct` to add methods
#   class Rectangle \
#     < I8::Struct.new( width: t.non_neg_int, length: t.non_neg_int )
#     
#     def area
#       width * length
#     end
#     
#   end # class Rectangle
# 
module Struct
  
  # Check args that were passed to {.new}.
  # 
  # @!visibility private
  # 
  # @param vector_prop_defs (see .new)
  # @param hash_prop_defs   (see .new)
  # 
  def self.check_new_args! vector_prop_defs, hash_prop_defs
    
    unless  (vector_prop_defs.empty? && !hash_prop_defs.empty?) ||
            (!vector_prop_defs.empty? && hash_prop_defs.empty?)
      
      raise NRSER::ArgumentError.new \
        "Exactly one of *args or **kwds must be empty",
        
        args: vector_prop_defs,
        
        kwds: hash_prop_defs,
        
        details: -> {%{
          {I8::Struct.new} proxies to either
          
          1.  {I8::Struct::Vector.new}
          2.  {I8::Struct::Hash.new}
          
          depending on *where* the property definitions are passed:
          
          1.  Positionally in `*args` -> {I8::Struct::Vector.new}
          2.  By name in `**kwds` -> {I8::Struct::Hash.new}
          
          Examples:
          
          1.  Create a Point struct backed by an {I8::Vector}:
              
                  Point = I8::Struct.new [x: t.int], [y: t.int]
              
          2.  Create a Point struct backed by an {I8::Hash}:
              
                  Point = I8::Struct.new x: t.int, y: t.int
          
        }}
      
    end # unless vector_prop_defs.empty? XOR hash_prop_defs.empty?
    
  end # .check_new_args!
  
  private_class_method :check_new_args!
  
  
  # @param [Array<Symbol>]
  def self.new *vector_prop_defs, **hash_prop_defs, &class_body
    check_new_args! vector_prop_defs, hash_prop_defs
    
    if !vector_prop_defs.empty?
      raise NotImplementedError.new "I8::Struct::Vector is TODO, sorry"
      # I8::Struct::Vector.new *vector_prop_defs, &class_body
    else
      I8::Struct::Hash.new **hash_prop_defs, &class_body
    end
  end
  
  
end # module Struct


# /Namespace
# ========================================================================

end # module I8

