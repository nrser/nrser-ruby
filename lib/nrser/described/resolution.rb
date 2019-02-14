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

# Mixing in my custom pretty printing
require 'nrser/support/pp'

require_relative './resolution/failed_error'


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

# Resolutions are internal objects used by descriptions to resolve their
# subjects or errors.
#
#
# Gory Details
# ----------------------------------------------------------------------------
#
# A {Resolution} instance takes a {Described::Base} instance (see {#described})
# and *one* of it's {SubjectFrom} instances (see {#subject_from}) and figures
# out how to assemble the values needed by the {SubjectFrom#parameters} so it
# can call it's {SubjectFrom#block}, producing either a {#subject} (if the block
# responds) or {#error} (if the block raises).
#
# When a {Described::Base} instance is {Described::Base#resolve!}-ing, it
# creates a {Resolution} for each of it's {Described::Base.subject_from}.
#
# {Resolution} collect values as well as other {Described::Base} instances that
# resolve to the desired values and wrap them both in {Resolution::Future}
# instances, with the understanding that some of the {Described::Base} will need
# to resolve against the {Hierarchy} before they can produce the desired
# {Described::Base#subject} or {Described::Base#error} values.
#
# The {Resolution::Future} instances are stored in {#resolved_futures}, keyed by
# the same name their {SubjectFrom::Parameter} is keyed by in the
# {SubjectFrom#parameters} hash of {#subject_from}.
#
# When {#resolved_futures} has a value for each parameter key, then the
# resolution can create a {#values} hash to feed into the {SubjectFrom#block} of
# {#subject_from}, completing the process.
#
# ### Construction *May* Be Completion ###
#
# The first thing a resolution does when it is constructed is go through the
# {Described::Base#init_values} of the {#described} instance, and pull whatever
# it can from there (it's assumed that if a value is provided to a description
# at construction, it is always meant to be used).
#
# If it satisfies all of the {SubjectFrom#parameters} from the init values, then
# the resolution will {#evaluate!} and be finished ({#resolved?} and
# {#evaluated?} will **both** be `true`).
#
# If there are parameters that are {SubjectFrom::InitOnly} instances that can
# **not** be satisfied by {#described}'s init values, then the resolution will
# **fail** at that time ({#failed?} will be `true`, and {#failed_because} will
# be non-`nil`), because there will be no way to successfully resolve down the
# line, no matter what {#update!} is called with.
#
# If neither of these occur, the resolution will be in a {#resolving?} state,
# and will require further {#update!} to resolve and evaluate.
#
# Hence it is important to check the state of resolutions after construction.
#
class Resolution
  
  # Mixins
  # ========================================================================
  
  include NRSER::Log::Mixin
  
  include NRSER::Support::PP
  
  
  # Config
  # ============================================================================
  
  pretty_print_config \
    ivars: false,
    methods: {
      always:   [ :resolved?, :evaluated? ],
      present:  [ :candidates,
                  :described,
                  :failed?,
                  :failed_because,
                  :subject_from,
                  :resolved_futures, ]
    }
  
  
  # Attributes
  # ========================================================================
  
  # The {SubjectFrom} instance entry in the {#described} instance class'
  # {Base.subject_from} that defines the resolution specification
  # {SubjectFrom#parameters} and subject creation block {SubjectFrom#block}.
  #
  # @return [SubjectFrom]
  #
  attr_reader :subject_from
  
  
  # Map fo {Symbol} names to {Future} instances (that are now or will in the
  # future be fulfilled by {Described::Base#subject} or {Described::Base#error}
  # values) that are currently resolved for those names.
  #
  # @return [Hash<Symbol, Future>]
  #
  attr_reader :resolved_futures
  
  
  # Map of name {Symbol}s from {SubjectFrom#parameters}'s keys to {Array}s of
  # {Future} instances that could become that parameter's {#resolved_future},
  # and hence provide that parameter's fully-resolved member of {#values}.
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
  # and one of the {SubjectFrom} instances in the {Base} class'
  # {Base.subject_from} array.
  #
  # @param [SubjectFrom] subject_from
  #   The {SubjectFrom} instance this resolution is for
  #   (an entry from the `described:` value's {Base.subject_from}).
  #
  # @param [Base] described
  #   The described instance to resolve from.
  # 
  # @param [Hierarchy] hierarchy
  #   The current description hierarchy, which is used to fulfill the 
  #   {Resolution::Future}s.
  #
  # @raise [NRSER::Types::CheckError]
  #   If the parameter values don't satisfy their types.
  #
  def initialize subject_from:, described:, hierarchy:
    require_relative './subject_from'
    
    logger.trace "Constructing resolution",
      for_described: described,
      subject_from: subject_from
    
    @subject_from = t( SubjectFrom ).check! subject_from
    @described = t( Base ).check! described
    @hierarchy = t( Hierarchy ).check! hierarchy
    
    # *Why* did we fail? When this is non-`nil`, we are in the {#failed?} state
    @failed_because = nil
    
    # Flag to flip when we have evaluated {#subject_from}'s 
    # {SubjectFrom#init_block}, meaning that either `@subject` or `@error` is 
    # then available.
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
      updated = subject_from.
        parameters.
        map { |name, parameter|
          
          t.match parameter,
            
            SubjectFrom::InitValue, -> {
              if  described.init_values.key?( name ) &&
                  (future = parameter.futurize( described.init_values[ name ] ))
                @resolved_futures[ name ] = future
                true
              
              # FIXME This... is not great / right / perfect. `nil` coming from
              #       a missing init value is problematic for things that accept
              #       {::Object} because `nil` *is* an {::Object}, causing them
              #       to use it, breaking shit.
              #       
              #       This is a bit of a band-aid: if the type is a 
              #       {Types::Maybe} then we know it really is optional and we
              #       try to use `nil`
              #       
              elsif parameter.type.is_a?( Types::Maybe ) &&
                    (future = parameter.futurize( nil ))
                @resolved_futures[ name ] = future
                true
                
              else
                # We're done - we can never successfully resolve because neither
                # `described`'s init values for `name` (which may be
                # `nil`) or `nil` satisfies the match extractor, and we have
                # nowhere else to get anything for it from.
                #
                # Mark the instance as un-resolvable and bail out.
                failed! "{#described} instance variables doesn't satisfy",
                        "type for *init-only* parameter", name, 
                        "(and `nil` doesn't either)",
                        name: name,
                        value: described.init_values[ name ],
                        parameter: parameter
                # return <- Doesn't return from method! Must raise 'n rescue:
                raise FailedError.new
              end # begin / rescue
            },
            
            SubjectFrom::Resolvable, ->{ 
              if described.init_values.key?( name )
                if (  future =
                        parameter.futurize( described.init_values[ name ] ) )
                  # add_candidate! name, future
                  @resolved_futures[ name ] = future
                  true
                end
              end
            }
            
        }.
        any?
        
      # If we updated the state at all, see if we got it already
      try_to_resolve! if updated && resolving?
      
      nil
    rescue FailedError => error
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
  # for descriptions with more than one {Described::Base.subject_from}, it is
  # unlikely that the necessary init values and description hierarchy are
  # always available for all {SubjectFrom}s, and many times the associated
  # {Resolution} instances can figure that out quickly and get out of the way by
  # failing.
  #
  # Resolutions may fail during construction: if the {#described} is missing
  # init-only values that the {#subject_from} needs (which can not be resolved 
  # from the hierarchy).
  # 
  # {Described::Method}'s `name` subject parameter is an example of this.
  #
  # It is hence important to check the failed state immediately after
  # constructing a {Resolution} in order to filter out early failures.
  #
  # @return [Boolean]
  #
  def failed?
    !@failed_because.nil?
  end
  
  
  # Has this instance set a {Resolution::Future} instance in {#resolved_futures}
  # for each of the {SubjectFrom#parameters} in its {#subject_from}?
  # 
  # @return [Boolean]
  # 
  def resolved?
    !failed? && resolved_futures.count == subject_from.parameters.count
  end
  
  
  # Has this instance neither {#failed?} nor {#resolved?}
  # 
  # @return [Boolean]
  # 
  def resolving?
    !( failed? || resolved? )
  end
  
  
  # Has this instance {#evaluate!}-ed, meaning that either {#subject} or 
  # {#error} is now available?
  # 
  # @return [Boolean]
  # 
  def evaluated?
    @evaluated
  end
  
  
  # Did this instance resolve to a {#subject} value (opposed to an {#error})?
  # 
  # @note
  #   In order to find out, **this method evaluates the resolution**, which will
  #   raise if it is not yet {#resolved?}.
  #   
  #   If you are not sure if the resolution has resolved and are not rescuing
  #   the error, use something like:
  #   
  #       resolution.resolved? && resolution.subject?
  # 
  # @return [Boolean]
  # 
  def subject?
    evaluate!
    instance_variable_defined? :@subject
  end
  
  
  # Did this instance resolve to an {#error} value (opposed to a {#subject})?
  # 
  # @note
  #   In order to find out, **this method evaluates the resolution**, which will
  #   raise if it is not yet {#resolved?}.
  #   
  #   If you are not sure if the resolution has resolved and are not rescuing
  #   the error, use something like:
  #   
  #       resolution.resolved? && resolution.error?
  # 
  # @return [Boolean]
  # 
  def error?
    evaluate!
    instance_variable_defined? :@error
  end
  
  # @!endgroup Public State Query Instance Methods # *************************
  
  
  # @!group Public State Assertion Instance Methods
  # --------------------------------------------------------------------------
  
  # Raise unless {#resolved?}.
  # 
  # @return [self]
  # 
  # @raise [UnresolvedError]
  #   If the resolution has not been {#resolved?}.
  # 
  def check_resolved!
    raise UnresolvedError.new( self: self ) unless resolved?
    self
  end
  
  # @!endgroup Public State Assertion Instance Methods # *********************
  
  
  # @!group Public Resolution Data Access Methods
  # --------------------------------------------------------------------------
  
  # The keyword arguments {::Hash} that will be provided to the 
  # {SubjectFrom#block} of {#subject_from} to obtain the {#subject} or {#error}.
  # 
  # @return [::Hash<Symbol, ::Object>]
  # 
  # @raise [UnresolvedError]
  #   If this instance is not {#resolved?}.
  # 
  def values
    @values ||= begin
      check_resolved!
      
      # Make sure all the futures are fulfilled
      resolved_futures.values.each { |future| future.fulfill! @hierarchy }
      
      resolved_futures.transform_values &:value
    end    
  end
  
  
  # The evaluated subject (response value from the {SubjectFrom#block} property
  # of {#subject_from} with {#values}).
  # 
  # @note
  #   Accessing this attribute causes evaluation (see {#evaluate!}), and will
  #   hence raise if the instance is not {#resolved?}.
  #   
  #   It will *also* raise if evaluation resulted in an {#error} instead.
  # 
  # @return [::Object]
  # 
  # @raise [UnresolvedError]
  #   If this instance is not {#resolved?}.
  # 
  # @raise [WrappedError<{cause: #error}>]
  #   If evaluation produced an {#error} value instead of a subject. {#error}
  #   will be the {WrappedError#cause}.
  # 
  def subject
    evaluate!
    
    unless subject?
      raise WrappedError.new \
        "Tried to access {#subject}, but subject instantiation caused an error",
        cause: @error
    end
    
    @subject
  end
  
  
  # The evaluation error (raised when calling the {SubjectFrom#block} property
  # of {#subject_from} with {#values}).
  # 
  # @note
  #   Accessing this attribute causes evaluation (see {#evaluate!}), and will
  #   hence raise if the instance is not {#resolved?}.
  #   
  #   It will *also* raise if evaluation resulted in a {#subject} instead.
  # 
  # @return [::Object]
  # 
  # @raise [UnresolvedError]
  #   If this instance is not {#resolved?}.
  # 
  # @raise [ConflictError<{subject: #subject, resolution: self}>]
  #   If evaluation produced a {#subject} value instead of an error.
  # 
  def error
    evaluate!
    
    unless error?
      raise ConflictError.new \
        "Tried to access {#error}, but subject instantiation succeeded",
        subject: @subject,
        resolution: self
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
    # @param [::Symbol] name
    #   The key in {#subject_from}'s {SubjectFrom#types} that `value` is a 
    #   candidate for.
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
      
      unless subject_from.parameters.key? name
        raise KeyError.new \
          "name #{ name.inspect } is not match extractor name in " + "
          {#subject_from}"
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
    # @return [nil]
    #   If everything's ok.
    # 
    # @raise [ConflictError]
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
        raise ConflictError.new \
          self.class, "has already", state,
          attempted_call: {
            method_name: method_name,
            args: args,
            block: block,
          },
          resolution: self
      end
      
      nil
    end # #check_resolving! 
    
    
    # Attempt to resolve the `@candidates` to `@values`.
    # 
    # @return [nil]
    #   Mutates the instance, in particular potentially chaning the {#resolved?}
    #   state.
    # 
    def try_to_resolve!
      check_resolving! __method__
      
      # Bail if there are still names with no candidates or values
      return if subject_from.parameters.keys.any? { |name|
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
      
      # To check, each `name` in `from.parameters` should appear in 
      # *exclusively either* `new_resolved_futures` or `resolved_futures`
      unless subject_from.parameters.keys.all? { |name|
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
      @resolved_futures.merge! new_resolved_futures
      
      nil
    end # #try_to_resolve!
    
    
    # Change to a *failed* state. From which there is no going back. This is
    # called when we know we will never succeed.
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
      @failed_because = [
        description.map { |value|
          value.is_a?( ::String ) ? value : value.inspect
        }.join( ' ' ),
        context
      ]
      
      self
    end # #failed!
    
    
    # Evaluate the {SubjectFrom#init_block} of {#subject_from} against 
    # {#values}, setting {#subject} if it succeeds, and {#error} if it fails.
    # 
    # Guards by checking and setting the {#evaluated?} state, so repeated calls
    # have no effect.
    # 
    # Also calls {#check_resolved!} to make sure we have resolved before it 
    # tries to evaluate.
    # 
    # @return [self]
    # 
    # @raise [ConflictError]
    #   If this resolution is not {#resolved?}.
    # 
    def evaluate!
      return self if evaluated?
      
      check_resolved!
      
      begin
        subject = subject_from.block.call( **values )
      rescue ::Exception => error
        @error = error
      else
        # If the type check raises it does **NOT** mean that the description
        # failed in an acceptable way that should set {#error} - init blocks
        # not returning a satisfactory type is a logic error, not something
        # to be tested for
        @subject = described.check_subject_type! subject, resolution: self
      end
      
      # Mark that we've successfully evaluated
      @evaluated = true
      
      self
    end # #evaluate!
    
  public # end protected *****************************************************
  
  
  def update! described, hierarchy
    check_resolving! __method__, described
    
    # `updated` should be set to `true` if we actually did any updating in this
    # flow, see the `.any?` at the end and notes throughout.
    updated = subject_from.
        parameters.
        # Select only resolvable parameters that we don't already have
        # resolved futures for (since we always want to use the 
        # {Described::Base#init_values} provided to the description at 
        # construction).
        select { |name, parameter|
          parameter.is_a?( SubjectFrom::Resolvable ) &&
            !resolved_futures.key?( name )
        }.
        # See if it makes sense to add a candidate {Future} for each extractor,
        # mapping to `true` if we do add one, so we can tell we updated, and
        # `nil` otherwise.
        map { |name, parameter|
          # See if we have a potential match, allowing us to skip descriptions
          # that have nothing to do with our needs
          if parameter.match? described
            # Ok, we're interested in this one! Resolve it so we can deal with 
            # the value directly 
            described.resolve! hierarchy
            
            # If we can construct a {Future} from the description, then add
            # it as a candidate
            if (future = parameter.futurize( described ))
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
    try_to_resolve! if updated
    
    # Allow for chaining... though I have considered returning a boolean to 
    # indicate if an update happen or not... but I'm not using that, and I don't
    # know why I continue to create unused APIs like that... I guess for that
    # future case where it might be useful...
    self
  end # #update!
  
end # class Resolution


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
