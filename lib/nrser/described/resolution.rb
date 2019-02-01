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


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
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
  
  
  # Map fo {Symbol} names to {Future} instances (that are now or will in the
  # future be fulfilled by {Described::Base#subject} or {Described::Base#error}
  # values) that are currently resolved for those names.
  #
  # @return [Hash<Symbol, Future>]
  #
  attr_reader :resolved_futures
  
  
  # Map of input name {Symbol}s to {Array}s of {Future} instances that could
  # become that input's {#resolved_future}, and hence it's future full-resolved
  # member of {#values}.
  # 
  # @return [Hash<Symbol, Array<Future>>]
  #     
  attr_reader :candidates
  
  
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
  
  
  # Construction
  # ==========================================================================
  
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
    require_relative './from'
    
    logger.trace "Constructing resolution",
      for_described: described,
      from: from
    
    @from = t( From ).check! from
    @described = t( Base ).check! described
    
    # A flag we throw via a call to {#failed!} when we know we can never 
    # resolve
    @failed = false
    
    # *Why* did we fail?
    @failed_because = nil
    
    # Flag to throw when we've successfully resolved all the name keys in 
    # `from`'s {From#match_extractors} to {Future} instances in
    # {#resolved_futures}
    @resolved = false
    
    # Flag to flip when we have evaluated {#from}'s {From#init_block}, meaning 
    # that either `@subject` or `@error` is then available.
    @evaluated = false
    
    # Where the final values go
    # Hash<Symbol, Future>
    @resolved_futures = {}
    
    # Where value {Candidate} instances go
    @candidates = Hash.new { |hash, name| hash[ name ] = [] }
    
    # Update from {#described}'s instance variables
    init_update_from_described!
  end
  
  
  protected
  # ========================================================================
    
    # Initialization helper to set values an candidates from {#described}'s
    # instance variables (the names and the {NRSER::Described::Base}
    # instance was initialized with, besides it's `@parent`).
    # 
    # @protected
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
      updated = from.
        match_extractors.
        map { |name, match_extractor|
          
          t.match match_extractor,
            
            From::InputValue, -> {
              # if match_extractor.match? described.inputs[ name ]
              #   add_value!  name,
              #               match_extractor.extract( described.inputs[ name ] ),
              #               source: __method__
              if (future = match_extractor.futurize( described.inputs[ name ] ))
                @inputs[ name ] = future
                true
              
              else
                # We're done - we can never successfully resolve because neither
                # `described`'s construction input for `name` (which may be `nil`)
                # or `nil` satisfies the match extractor, and we have nowhere else
                # to get anything for it from.
                #
                # Mark the instance as un-resolvable and bail out.
                failed! "{#described} instance variables doesn't satisfy",
                        "construction-input-only type (and `nil` doesn't either)",
                        name: name,
                        value: value,
                        type: type
                return
              end # begin / rescue
            },
            
            From::Resolvable, ->{ 
              if described.inputs.key?( name )
                if (future = match_extractor.futurize( described ))
                  add_candidate! name, future
                  true
                end
              end
            }
            
        }.
        any?
        
      # If we updated the state at all, see if we got it already
      try_to_resolve! if updated
      
      nil
    end # init_update_from_described!
  
  public # end protected *****************************************************
  
  
  # Instance Methods
  # ==========================================================================
  
  # @!group Public State Query Instance Methods
  # --------------------------------------------------------------------------
  # 
  # Instance methods for checking the state of the resolution.
  # 
  # **WARNING** Some methods trigger side-effects and/or raise if called from
  #             the wrong state!
  # 
  
  # Is it no longer possible for this resolution to succeed?
  #
  # This is an expected state for some of a description's resolutions, because
  # for descriptions with more than one {Described::Base.from}, it is unlikely
  # that the necessary input values and description hierarchy are always
  # available for all {From}s, and many times the associated {Resolution}
  # instances can figure that out quickly and get out of the way by failing.
  #
  # Resolutions may fail during construction: if the {#described} is missing
  # input values that the {#from} needs that can not be resolved from the
  # hierarchy ({Described::Method}'s `name` input falls in this category).
  #
  # It is hence important to check the failed state immediately after
  # constructing a {Resolution} in order to filter out early failures.
  # 
  # @return [Boolean]
  #
  def failed?
    @failed
  end
  
  
  def resolved?
    @resolved
  end
  
  
  def evaluated?
    @evaluated
  end
  
  
  def fulfilled?
    @fulfilled
  end
  
  
  def subject?
    evaluate!
    instance_variable_defined? :@subject
  end
  
  
  def error?
    evaluate!
    instance_variable_defined? :@error
  end
  
  # @!endgroup Public State Query Instance Methods # *************************
  
  
  # @!group Public State Assertion Instance Methods
  # --------------------------------------------------------------------------
  
  # @return [self]
  # 
  # @raise [Resolution::UnresolvedError]
  #   If the resolution has not been {#resolved?}.
  # 
  def check_resolved!
    raise Resolution::UnresolvedError.new( self: self ) unless resolved?
    self
  end
  
  
  def check_fulfilled!
    raise "Not fulfilled!" unless fulfilled?
    self
  end
  
  # @!endgroup Public State Assertion Instance Methods # *********************
  
  
  # @!group Public Resolution Data Access Methods
  # --------------------------------------------------------------------------
  
  def values
    @values ||= begin
      check_resolved!
      check_fulfilled!
      
      resolved_futures.transform_values &:value
    end    
  end
  
  
  def subject
    evaluate!
    
    unless subject?
      raise NRSER::WrappedError.new \
        "Tried to access {#subject}, but subject instantiation caused an error",
        cause: @error
    end
    
    @subject
  end
  
  
  def error
    evaluate!
    
    unless error?
      raise NRSER::ConflictError.new \
        "Tried to access {#error}, but subject instantiation succeeded",
        subject: @subject,
        self: self
    end
    
    @error
  end
  
  # @!endgroup Public Resolution Data Access Methods # ***********************
  
  
  protected
  # ========================================================================
    
    # Create a {Candidate} and add it to `@candidates`, checking that it makes
    # sense to do so.
    # 
    # @note
    #   This is the **ONLY** way the list of candidates should be manipulated.
    # 
    # @protected
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
    # @return [Future]
    #   The {Future} that was added to {#candidates}.
    # 
    def add_candidate! name, future #, source:, **context
      check_resolving! __method__, future #, value, source: source, **context
      
      unless from.match_extractors.key? name
        raise KeyError.new \
          "name #{ name.inspect } is not match extractor name in {#from}"
      end
      
      if resolved_futures.key? name
        raise NRSER::ConflictError.new \
          "Type", name, "already resolved to value ", values[ name ].inspect
      end
      
      @candidates[ name ] << future
      
      future
    end
    
    
    # Called before doing something that only make sense if the {Resolution}
    # is in the process of resolving (like adding a candidate value for a type).
    # 
    # @protected
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
    # @protected
    # 
    # @return [nil]
    #   Mutates the instance, in particular potentially chaning the {#resolved?}
    #   state.
    # 
    def try_to_resolve! hierarchy: nil
      check_resolving! __method__
      
      # Bail if there are still names with no candidates or values
      return if from.match_extractors.keys.any? { |name|
        !@candidates.key?( name ) && !resolved_futures.key?( name )
      }
      
      # Create a working copy of `@candidates` to mutate, discarding candidates
      # for the same value that have equal {Candidate#value}
      candidates = @candidates.transform_values { |futures|
        futures.uniq &:uniq_id
      }
      
      # And a hash to store hopefully resolved {Future} instance that have
      # or will have the values we need.
      new_resolved_futures = {}
      
      # The whole goal is to empty out that `candidates` hash, bailing out of
      # the entire method (without having mutated any instance variables) if
      # we run into problems
      until candidates.empty?
        
        # Create a hash of candidates names to single {Candidate} for *only*
        # names that have a single {Candidate}.
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
        return if unique_candidates.count != \
                    unique_candidates.
                      values.
                      uniq( &:uniq_id ).
                      count
        
        # Remove all the unique names from the working copy
        unique_candidates.keys.each { |name| candidates.delete name }
        
        # Remove those candidates from any other names and store their futures
        # in the new ones hash
        unique_candidates.each do |name, unique_future|
          new_resolved_futures[ name ] = unique_future
          
          candidates.each do |name, other_futures|
            other_futures.reject! do |other_future|
              other_future == unique_future
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
            return if other_futures.empty?
          end # candidates.each
        end # unique_candidates.each
        
        # Ok, go around again if needed...
        
      end # until candidates.empty?
      
      # Shit... this should mean we've actually done it!
      
      # To check, each `name` in `from.match_extractors` should appear in 
      # *exclusively either* `new_resolved_futures` or `resolved_futures`
      unless from.match_extractors.keys.all? { |name|
        if new_resolved_futures.key?( name )
          !resolved_futures.key?( name )
        else
          resolved_futures.key?( name )
        end
      }
        raise NRSER::RuntimeError.new \
          "Logic failure...  some names in both...",
          new_resolved_futures:   new_resolved_futures,
          resolved_futures:       resolved_futures
      end
      
      # Now just assign and flag the state!
      resolved_futures.merge! new_resolved_futures
      @resolved = true 
      
      if hierarchy
        resolved_futures.each do |name, future|
          future.fulfill! hierarchy
        end
        
        @fulfilled = true
      end
      
      nil
    end # #try_to_resolve!
    
    
    # Change to a *failed* state. From which there is no going back. This is
    # called when we know we will never succeed.
    # 
    # @protected
    # 
    # @param [Array] description
    #   Entries to be merged into a {::String} description.
    # 
    # @param [Hash<Symbol, Object>] context
    #   Names and values of relevant information.
    # 
    # @return [self]
    #   
    def failed! *description, **context
      @failed = true
      @failed_because = [
        description.map { |value|
          value.is_a?( ::String ) ? value : value.inspect
        }.join( ' ' ),
        context
      ]
      
      self
    end # #failed!
    
    
    # Evaluate the {From#init_block} of {#from} against {#values}, setting 
    # {#subject} if it succeeds, and {#error} if it fails.
    # 
    # Guards by checking and setting the {#evaluated?} state, so repeated calls
    # have no effect.
    # 
    # @private
    # 
    # @return [self]
    # 
    def evaluate!
      return self if evaluated?
      
      begin
        subject = from.init_block.call( **values )
      rescue ::Exception => error
        @error = error
      else
        # If the type check raises it does **NOT** mean that the description
        # failed in an acceptable way that should set {#error} - init blocks
        # not returning a satisfactory type is a logic error, not something
        # to be tested for
        @subject = described.class.subject_type.check! subject
      end
      
      @evaluated = true
      
      self
    end # #evaluate!
    
  public # end protected *****************************************************
  
  
  def update! described, hierarchy
    check_resolving! __method__, described
    
    # Maybe... this would allow us to avoid passing `hierarchy` to 
    # {#try_to_resolve!}, but it also might end up with us doing more work than
    # necessary or even desired resolving futures that we won't have any need 
    # of..?
    # 
    # TODO  If not, we def want to resolve any pending futures *before* we 
    #       start to iterate through the `hierarchy` for the case where we 
    #       have all the inputs already filled out from construction but
    #       some need to be resolved in order for this instance to resolve.
    # 
    # resolve_futures! hierarchy
    
    # 
    updated = from.
        match_extractors.
        # Select only resolvable match extractors that we don't already have
        # set input futures for (since we always want to use the constructor
        # inputs)
        select { |name, match_extractor|
          match_extractor.is_a?( From::Resolvable ) &&
            !resolved_futures.key?( name )
        }.
        # See if it makes sense to add a candidate {Future} for each extractor,
        # mapping to `true` if we do add one, so we can tell we updated, and
        # `nil` otherwise.
        map { |name, match_extractor|
          # See if we have a potential match, allowing us to skip descriptions
          # that have nothing to do with our needs
          if match_extractor.match? described
            # Ok, we're interested in this one! Resolve it so we can deal with 
            # the value directly 
            described.resolve! hierarchy
            
            # If we can construct a {Future} from the description, then add
            # it as a candidate
            if (future = match_extractor.futurize( described ))
              add_candidate! name, future
              # Evaluate the block to `true` to signal that we have updated
              # state and will want to try to resolve
              true
            end
          end
        }.
        # See if any of the above blocks added a candidate, the result of which
        # gets assigned to `updated`
        any?
    
    # Attempt to resolve, this time providing the {Hierarchy}, which will allow
    # any futures to be resolved.
    try_to_resolve!( hierarchy: hierarchy ) if updated
    
    # Allow for chaining... though I have considered returning a boolean to 
    # indicate if an update happen or not... but I'm not using that, and I don't
    # know why I continue to create unused APIs like that... I guess for that
    # future case where it might be useful...
    self
  end
  
  
  # Language Integration Instance Methods
  # --------------------------------------------------------------------------
  
  def pretty_print pp
    pp.group(1, "{#{self.class}", "}") do
      pp.breakable ' '
      pp.seplist(
        instance_variables.sort.
          map { |var_name|
            [ var_name.to_s[ 1..-1 ], instance_variable_get( var_name ) ]
          }.
          reject { |(name, value)|
            name != 'resolved' &&
            name != 'evaluated' &&
            ( value.nil? ||
              value == false ||
              ( value.respond_to?( :empty? ) && value.empty? ) )
          },
        nil
      ) do |(name, val)|
        pp.group do
          pp.text "#{ name }: "
          pp.group(1) do
            pp.breakable ''
            val.pretty_print(pp)
          end
        end
      end
    end
  end
  
end # class Resolution


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
