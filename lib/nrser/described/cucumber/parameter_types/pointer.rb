# encoding: UTF-8
# frozen_string_literal: true
# doctest: true


# Requirements
# ============================================================================

### Stdlib ###

### Deps ###

require 'concurrent/atomic/atomic_fixnum'

### Project / Package ###


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  ParameterTypes


# Definitions
# ============================================================================

# A {Pointer} is an structure used to reference an object by it's `#object_id`
# and retrieve it again at a later time.
# 
# 
# WTF..?
# ----------------------------------------------------------------------------
#
# Why? You can put a {Pointer} through marshaling and un-marshaling and still
# use it get the *exact* object back.
# 
# @example Through marshal and back again
#   
#   # Object we want to reference
#   object = Object.new
#   
#   # Create a pointer to it
#   pointer = ::NRSER::Described::Cucumber::ParameterTypes::Pointer.create object
#   
#   # The pointer stores it's `#object_id`
#   pointer.target_object_id == object.object_id
#   #=> true
#   
#   # By default a reference to the object is also stored globally so it won't 
#   # get garbage collected (can be disabled in {.create} arguments, see below).
#   
#   # Now dump and re-load the pointer
#   dump = Marshal.dump pointer
#   loaded_pointer = Marshal.load dump
#   
#   # This gives a new {Pointer} *instance*
#   
#   loaded_pointer.is_a? ::NRSER::Described::Cucumber::ParameterTypes::Pointer
#   #=> true
#   
#   pointer.equal? loaded_pointer
#   #=> false
#   
#   # But "pointing" to the same object
#   loaded_pointer.target_object_id == pointer.target_object_id
#   #=> true
#   
#   # And the {#target} we get *is* the original object!
#   object.equal? loaded_pointer.target
#   #=> true
# 
# Ok... but, *why*? Because, for some reason - that I have not had the time or 
# heart to look into - Cucumber attempts to duplicate parameter values by first
# marshaling them, then un-marshaling them.
# 
# The relevant method is {Cucumber::StepMatch#deep_clone_args}, which you can 
# see here:
# 
# <https://github.com/cucumber/cucumber-ruby/blob/33632fc4efa6817d36479ea862235bf1bfccfa55/lib/cucumber/step_match.rb#L97>
#
# This totally fucks up our Christmas, because in many cases we want exactly 
# what we want, *not a copy* - {Described::Base} instances from the hierarchy,
# classes, procs, constants... even to just test that something is actually
# identical to something else.
#
# So, that's what this is for. And it seems to work.
#
class Pointer
  
  # Class Variables
  # ==========================================================================
  
  # Where we keep references (to prevent targets getting GC'd if all their 
  # other references go away).
  @@references = {}
  
  
  # Singleton Methods
  # ==========================================================================
  
  # Clear out any target references that were previously saved with {.create}.
  # 
  # This is really just here for completeness... this class is *really* not 
  # meant for any use outside of the intended Cucumber runs, and those should
  # hopefully never be long-running enough or passing large enough objects
  # through parameters to worry about the memory usage.
  # 
  # @return [nil]
  # 
  def self.clear_references
    @@references = {}
    nil
  end
  
  
  # Delete the reference to a single object. You might need this if you're 
  # testing GC and have passed the object as a step parameter.
  # 
  # @note
  #   Return value won't make sense if the object in question is `nil` itself.
  #   
  #   Don't store pointers to `nil`. It's stupid and weird. See {.needed?}.
  # 
  # @param [::Integer] object_id
  #   ID of the object.
  # 
  # @return [false]
  #   When there wasn't a reference to it stored.
  # 
  # @return [true]
  #   There was a reference stored.
  # 
  def self.delete_reference object_id
    deleted = @@references.delete object_id
    
    deleted.object_id == object_id
  end
  
  
  # Create a {Pointer} to an `object`.
  # 
  # @param [::Object] object
  #   Object you want to point to.
  # 
  # @param [Boolean] save_ref
  #   When `true`, a reference to the object will be stored in a class variable.
  #   
  #   This prevents the object from getting garbage collected. You can give 
  #   `false` if you're sure the object will still be alive when you want it
  #   back.
  # 
  # @return [Pointer]
  #   The new pointer.
  # 
  def self.create object, save_ref: true
    object_id = object.object_id
    
    if save_ref
      @@references[ object_id ] = object
    end
    
    new object.object_id
  end
  
  
  # Do we need to create a pointer to this object? "Value" objects will still be
  # identical no matter how they are created, and there's no need to point to
  # them.
  # 
  # The list is:
  # 
  # 1.  `nil`
  # 2.  `true` and `false`
  # 3.  {::Integer} instances
  # 4.  {::Symbol} instances
  # 
  # @param [::Object] object
  #   Object to test.
  # 
  # @return [Boolean]
  #   `true` if there's no need to point to `object`.
  # 
  def self.needed? object
    case object
    when nil, true, false, ::Integer, ::Symbol
      false
    else
      true
    end
  end
  
  
  # Attributes
  # ==========================================================================
  
  # `#object_id` of the {#target}.
  # 
  # @return [::Integer]
  #     
  attr_reader :target_object_id
  
  
  # Construction
  # ==========================================================================
  
  # Instantiate a new `Pointer`.
  # 
  # @note
  #   You *probably* want to use {.create} to make instances... this doesn't 
  #   save references to them.
  # 
  # @param [::Integer] target_object_id
  #   `#object_id` of the {#target}.
  # 
  def initialize target_object_id
    @target_object_id = target_object_id
  end # #initialize
  
  
  # Instance Methods
  # ==========================================================================
  
  # Dereference the pointed-to object.
  # 
  # First checks the references stored in the class variable. If it's not there,
  # tries {::ObjectSpace._id2ref}.
  # 
  # Only resolves the target object on the first call, storing it in an 
  # instance variable after that.
  # 
  # @todo
  #   Should this just resolve the value every time?
  # 
  # @return [::Object]
  #   The target object.
  # 
  # @raise [::RangeError]
  #   Seems to be what {::ObjectSpace._id2ref} throws when things go wrong?
  # 
  # @raise [::NotFoundError]
  #   If we got something back with the wrong `#object_id`. IDK how 
  #   {::ObjectSpace._id2ref} works, so I check just in case.
  # 
  def target
    unless instance_variable_defined? :@target
      target = begin
        @@references.fetch target_object_id
      rescue ::KeyError => error
        ::ObjectSpace._id2ref target_object_id
      end
      
      unless target.object_id == target_object_id
        raise NotFoundError.new \
          "Could not find object with id", target_object_id
      end
      
      @target = target
    end
    
    @target
  end # #target
  
end # class Pointer


# /Namespace
# =======================================================================

end # module ParameterTypes
end # module Cucumber
end # module Described
end # module NRSER
