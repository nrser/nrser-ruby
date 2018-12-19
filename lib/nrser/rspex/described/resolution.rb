# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# ------------------------------------------------------------------------

require 'set'

# Deps
# ----------------------------------------------------------------------------

require 'active_support/core_ext/hash/transform_values'

# Project / Package
# -----------------------------------------------------------------------

# {Resolution::Error} mixes in {NRSER::NicerError}
require 'nrser/errors/nicer_error'

# Mixing logging in
require 'nrser/log'

# {Resolution}s track value candidates in {Candidate} instances
require_relative './resolution/candidate'

require_relative './from'


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  RSpex
module  Described


# Definitions
# =======================================================================

class Resolution
  
  # Mixins
  # ========================================================================
  
  include NRSER::Log::Mixin
  
  
  # Attributes
  # ========================================================================
  
  # The {From} instance entry in the {#described} instance class' {Base.from}
  # that defines the resolution specification {From#types} and subject creation
  # block {From#init_block}.
  # 
  # @return [From]
  #     
  attr_reader :from
  
  
  # The described instance to resolve a {Base#subject} for.
  # 
  # @return [Base]
  #     
  attr_reader :described
  
  
  # Some data indicating *why* resolution failed.
  # 
  # @return [nil]
  #   When resolution has not failed (at least not yet).
  # 
  # @return [Array]
  #   When resolution has failed ({#failed?} responds with `true`).
  #     
  attr_reader :failed_because
  
  
  # Construct a new {Resolution} for resolving the subject for a {Base} instance
  # and one of the {From} instances in the {Base} class' {Base.from} array.
  # 
  # @param [From] from 
  #   The {From} instance this resolution is for (an entry from the `described:`
  #   value's {Base.from}).
  # 
  # @param [Base] described
  #   The described instance to resolve from.
  # 
  # @raise [NRSER::Types::CheckError]
  #   If the parameter values don't satisfy their types.
  #   
  def initialize from:, described:
    @from = t( From ).check! from
    @described = t( Base ).check! described
    
    # A flag we throw via a call to {#failed!} when we know we can never 
    # resolve
    @failed = false
    
    # *Why* did we fail?
    @failed_because = nil
    
    # Flag to throw when we've successfully resolved
    @resolved = false
    
    # Where the final values go
    @values = {}
    
    # Where value {Candidate} instances go
    @candidates = Hash.new { |hash, name| hash[ name ] = [] }
    
    # Split the {From#types} into:
    #
    # 1.  `@ivar_only_types` - "Instance-variable-only" types that can *only*
    #     take values from the instance variable of the same name in
    #     `described`.
    #     
    # 2.  `@resolvable_types` - Types whose values can come from `described`
    #     instance variables (which get first priority) *or* from subjects up
    #     the ancestor chain.
    #     
    @ivar_only_types, @resolvable_types = \
      from.types.
        partition { |name, type| name.to_s.start_with? '@' }.
        map { |array| array.to_h.freeze }
    
    # Update from {#described}'s instance variables
    init_update_from_described!
  end
  
  
  private
  # ========================================================================
    
    # Initialization helper to set values an candidates from {#described}'s
    # instance variables (the names and the {NRSER::RSpex::Described::Base}
    # instance was initialized with, besides it's `@parent`).
    # 
    # @private
    # 
    # @return [nil]
    #   Mutates the instance.
    # 
    def init_update_from_described!
      # Assign to `@values` for each of the "instance-variable-only" types,
      # since the only place we can get them is from `described`, and we've got
      # it here and now.
      #
      # If there's something in there that we can't satisfy then we know we've
      # failed now and don't have to do any additional work.
      # 
      # @note
      #   This method will put the instance in a **failed** state if there are
      #   instance-variable-only types that are not satisfied by {#described}'s
      #   instance variable value or `nil`.
      #   
      #   Check if {Resolution} instances have {#failed?} after initialization
      #   to avoid doing any additional unnecessary work on their behalf.
      #
      @ivar_only_types.each do |ivar_name, type|
        # Get the regular name by chopping off the '@' prefix
        name = ivar_name.to_s[ 1..-1 ].to_sym
        
        value = described.instance_variable_get ivar_name
        
        if type.test? value
          # The value (which may be `nil`) satisfies the type, so use it.
          @values[ name ] = value
        elsif !value.nil? && type.test?( nil )
          # Otherwise, if `value` *wasn't* `nil`, we need to check if `nil`
          # satisfies the `type` (it may be an optional parameter indicated by a
          # `t.Maybe` type or similar)
          @values[ name ] = nil
        else
          # We're done - we can never successfully resolve because neither
          # `described@<name>` (which may be `nil`) or `nil` satisfies `type`,
          # and we have nowhere else to get anything for it from.
          #
          # Mark the instance as un-resolvable and bail out.
          failed! "{#described} instance variables doesn't satisfy",
                  "instance-variable-only type (and `nil` doesn't either)",
                  name: name,
                  value: value,
                  type: type
          return
        end
        
        nil
      end # @ivar_only_types.each
      
      # Now swing through the resolvable types and see if {#described} has
      # instance variable values that satisfy them. If so, those values will 
      # become candidates.
      @resolvable_types.each do |name, type|
        ivar_name = "@#{ name }"
        
        if described.instance_variable_defined? ivar_name
          value = described.instance_variable_get ivar_name
          
          # If the `type` represents a {Base} subclass then we want to check the
          # value against that subclass' {Base.subject_type} as well, since 
          # {#described}'s instance variables will be actual values, not 
          # described instances with {Base#subject} values.
          # 
          # TODO  This seems to work, but it's kind-of funky... could probably 
          #       use some improvement.
          # 
          if (  type.is_a?( t::IsA ) && Base.subclass?( type.mod ) &&
                type.mod.subject_type.test?( value ) ) ||
                type.test?( value )
            add_candidate! name, value, method: __method__, source: ivar_name
          end
        end
      end # @resolvable_types.each
      
      # See if we got it already
      try_to_resolve!
      
      nil
    end
    
    
    # Create a {Candidate} and add it to `@candidates`, checking that it makes
    # sense to do so.
    # 
    # @note
    #   This is the **ONLY** way the list of candidates should be manipulated.
    # 
    # @private
    # 
    # @param [::Symbol] name
    #   The key in {#from}'s {From#types} that `value` is a candidate for.
    #   
    #   **MUST** also be a key in `@resolvable_types`: only resolvable types
    #   can have candidates because name/type pairs partitioned into 
    #   `@ivar_only_types` can **only** be resolved from {#described}'s instance
    #   variables, where there is no ambiguity (handled at construction in 
    #   {#init_update_from_described!}).
    # 
    # @param [::Object] value
    #   The candidate value (becomes the {Candidate#value}).
    # 
    # @param [#to_s] source
    #   Information about where the `value` came from to set as the 
    #   {Candidate#source} - useful for debugging / error reporting.
    # 
    # @param [Hash<::Symbol, ::Object>] context
    #   Any other information about where the `value` is coming from that would
    #   be useful in errors (passed to {#check_resolving!} along with the other
    #   parameters).
    # 
    # @return [Candidate]
    #   The newly constructed {Candidate} instance, which has been added to 
    #   `@candidates`.
    # 
    def add_candidate! name, value, source:, **context
      check_resolving! __method__, name, value, source: source, **context
      
      unless @resolvable_types.key? name
        raise KeyError.new \
          "name #{ name.inspect } is not a resolvable type"
      end
      
      if @values.key? name
        raise NRSER::ConflictError.new \
          "Type", name, "already resolved to value", @values[ name ]
      end
      
      Candidate.
        new( value: value, source: source.to_s ).
        tap { |candidate| @candidates[ name ] << candidate }
    end
    
    
    # Called before doing something that only make sense if the {Resolution}
    # is in the process of resolving (like adding a candidate value for a type).
    # 
    # @private
    # 
    # @return [nil]
    #   If everything's ok.
    # 
    # @raise [NRSER::ConflictError]
    #   If everything is **not** ok. The error's `#context` includes a lot of 
    #   useful information for figuring out where it all went wrong.
    # 
    def check_resolving! method_name, *args, &block
      state = if failed?
        "FAILED"
      elsif resolved?
        "RESOLVED"
      end
      
      if state
        raise NRSER::ConflictError.new \
          self.class, "has already", state,
          attempted_call: {
            method_name: method_name,
            args: args,
            block: block,
          },
          from: from,
          described: described
      end
      
      nil
    end # #check_resolving! 
    
    
    # Attempt to resolve the `@candidates` to `@values`.
    # 
    # @private
    # 
    # @return [nil]
    #   Mutates the instance, in particular potentially chaning the {#resolved?}
    #   state.
    # 
    def try_to_resolve!
      check_resolving! __method__
            
      no_candidates = @resolvable_types.keys - @candidates.keys
      
      # Bail if there are still names with no candidates
      return unless no_candidates.empty?
      
      # Create a working copy of `@candidates` to mutate
      candidates = @candidates.transform_values &:dup
      
      # And a hash to store hopefully resolved values
      resolved_values = {}
      
      # The whole goal is to empty out that `candidates` hash, bailing out of
      # the entire method (without having mutated any instance variables) if
      # we run into problems
      until candidates.empty?
      
        unique_candidates = \
          candidates.
            select { |name, entries| entries.count == 1 }.
            transform_values( &:first )
        
        # If there are no unique candidates we give up (for now)
        return if unique_candidates.empty?
        
        # If there are any duplicates, we also give up, because there's no way
        # we can resolve everything (it has to leave at least one of the names
        # with no candidates).
        # 
        # This is something like:
        # 
        #     n_1: [ A ]
        #     n_2: [ A ]
        # 
        # I do this by checking if a {::Set} of the {Candidate#value} object IDs
        # is the same count as the {::Hash} of unique candidates. And I sort 
        # of think that works...
        # 
        return if unique_candidates.count != unique_candidates.
            values.
            map { |c| c.value.object_id }.
            to_set.
            count
        
        # Remove all the unique names from the working copy
        unique_candidates.keys.each { |name| candidates.delete name }
        
        # Remove those candidates from any other names and store their values
        # in the new ones hash
        unique_candidates.each do |name, unique_candidate|
          resolved_values[ name ] = unique_candidate.value
          
          candidates.each do |name, entries|
            entries.reject! do |candidate|
              candidate.value.equal? unique_candidate.value
            end
            
            # If this completely emptied the candidates list, then we give up.
            # 
            # This would happen for something like:
            # 
            #     n_1: [ A ]
            #     n_2: [ B ]
            #     n_3: [ A, B ]
            # 
            # Names `n_1` and `n_2` both have unique candidates `A` and `B`,
            # respectively, but when they're removed there will be nothing left
            # for `n_3`.
            # 
            return if entries.empty?
          end # candidates.each
        end # unique_candidates.each
        
        # Ok, go around again if needed...
        
      end # until candidates.empty?
      
      # Shit... this should mean we've actually done it!
      # 
      # So, `resolved_values` should have the same amount of entries as
      # `@resolvable_types`
      unless resolved_values.count == @resolvable_types.count
        raise NRSER::RuntimeError.new \
          "Logic failure...  counts don't match",
          resolved_values:  resolved_values,
          resolvable_types:   @resolvable_types
      end
      
      # Now just assign and flag the state!
      @values.merge! resolved_values
      @resolved = true 
      
      nil
    end # #try_to_resolve!
    
    
    # Change to a *failed* state. From which there is no going back. This is
    # called when we know we will never succeed.
    # 
    # @private
    # 
    # @param [Array] description
    #   Entries to be merged into a {::String} description.
    # 
    # @param [Hash<Symbol, Object>] context
    #   Names and values of relevant information.
    # 
    # @return [nil]
    #   
    def failed! *description, **context
      @failed = true
      @failed_because = [
        description.map { |value|
          value.is_a?( ::String ) ? value : value.inspect
        }.join( ' ' ),
        context
      ]
      nil
    end # #failed!
    
  public # end private *****************************************************
  
  
  def failed?
    @failed
  end
  
  
  def resolved?
    @resolved
  end
  
  
  def update! described
    check_resolving! __method__, described
    
    @resolvable_types.each do |name, type|
      if type.test? described
        add_candidate! name, described.subject,
          method: __method__,
          source: described
      end
    end
    
    try_to_resolve!
    
    nil
  end
  
  
  def subject
    return @subject if instance_variable_defined? :@subject
    
    unless resolved?
      raise NRSER::RuntimeError.new \
        self.class, "must be {#resolved?} to get {#subject}",
        resolution: self
    end
    
    from.init_block.call **@values
  end
  
end # class Resolution


# /Namespace
# =======================================================================

end # module Described
end # module RSpex
end # module NRSER
