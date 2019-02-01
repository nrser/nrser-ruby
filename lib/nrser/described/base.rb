# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

require 'set'

# Deps
# -----------------------------------------------------------------------

# Using {::String#underscore}, {::String#demodulize}, and {::String#humanize}
require 'active_support/core_ext/string/inflections'

# Project / Package
# -----------------------------------------------------------------------

# Mixing logging in
require 'nrser/log'

# {Base.Names} provides shortcut to {NRSER::Meta::Names}
require 'nrser/meta/names'

# Using {Resolution} in {Base#resolve_subject!}
require_relative './resolution'

# {Resolution#resolve_subject!} raises {Resolution::AllFailedError}
require_relative './resolution/all_failed_error'

# {Resolution#resolve!} raises {Resolution::UnresolvedError}
require_relative './resolution/unresolved_error'


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

# Abstract base class for all description objects.
# 
# Description objects are a bit like an extension of {RSpec}'s explicit subject 
# functionality.
# 
# @abstract
# 
class Base

  # Mixins
  # ========================================================================
  
  include NRSER::Log::Mixin
  
  
  # Constants
  # ========================================================================
  
  RESOLUTION_TYPE = t.IsA( Resolution ) & t.Attributes( :resolved? => true )
  
  
  # Singleton Methods
  # ========================================================================
  
  # Shortcut to {NRSER::Meta::Names} to make {.from} declarations more 
  # concise.
  # 
  # @return [::Module]
  #   {NRSER::Meta::Names}
  # 
  def self.Names
    NRSER::Meta::Names
  end
  
  
  # @return [From]
  #   The new {From} instance.
  # 
  def self.from **match_extractors, &init_block
    # Need to require here to prevent {Base} -> {From} -> {Base} loop
    require_relative './from'
  
    @from ||= []
    
    if match_extractors.empty?
      unless init_block.nil?
        raise NRSER::ArgumentError.new \
          "Must provide `name`/{MatchExtractor} pairs when declaring a {From}"
      end
      
      return @from
    end
    
    From.
      new( match_extractors: match_extractors, init_block: init_block, ).
      tap { |from| @from << from }
  end
  
  
  def self.subject_type *args
    case args.length
    when 0
      # pass - it's just a get
    when 1
      # set
      value = args[ 0 ]
      
      unless @subject_type.nil?
        raise NRSER::ConflictError.new \
          "{.subject_type} already set",
          set_subject_type: @subject_type,
          provided_value: value
      end
      
      @subject_type = t.make value
      
    else
      raise NRSER::ArgumentError.new \
        "{.subject_type} accepts at most one argument, received", args,
        args: args
    end
    
    @subject_type
  end # .subject_type
  
  
  def self.subclass? object
    object.is_a?( ::Class ) && object < self
  end
  
  
  # The default standard "human" name for the class (as used in Cucumber 
  # features) based on the class' "demodulized" name (the last segment / 
  # "namespace-less" name).
  # 
  # @example
  #   NRSER::Described::InstanceMethod.default_human_name
  #   #=> "instance method"
  # 
  # @return [String]
  # 
  def self.default_human_name
    name.demodulize.underscore.humanize capitalize: false
  end # .default_human_name
  
  
  # @todo Document alternative_human_names method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.alternative_human_names *names
    @alternative_human_names ||= []
  
    @alternative_human_names.push( *names ) unless names.empty?
    
    @alternative_human_names
  end # .alternative_human_names
  
  
  # All human names for the class: {.default_human_name} plus any alternatives
  # declared with {.alternative_human_names}.
  # 
  # @return [::Array<::String>]
  # 
  def self.human_names
    [ default_human_name, *alternative_human_names ]
  end # .human_names
  
  
  # Attributes
  # ========================================================================
  
  # The {Resolution} used to set {#subject}, if any.
  # 
  # @return [nil]
  #   Either:
  #   
  #   1.  
  # 
  # @return [Resolution]
  #   The resolution used to set {#subject}.
  #     
  attr_reader :resolution
  
  
  # 
  # 
  # @return [I8::Hash<Symbol, Object>]
  #     
  attr_reader :inputs
  
  
  # Construction
  # ========================================================================
  
  # Instantiate a new `Base`.
  # 
  # @param [Hash<Symbol, Object>] values
  #   
  # 
  def initialize **kwds
    @resolving = false
    @resolution = nil
    @resolved = false
    
    @error = nil
    
    if kwds.key? :subject
      self.subject = kwds[ :subject ]
      kwds.delete :subject
      @resolved = true
    end
    
    @inputs = I8::Hash[ kwds ]
    
  end # #initialize
  
  
  # Instance Methods
  # ========================================================================
  
  
  def subject?
    check_resolved!
    instance_variable_defined? :@subject
  end
  
  
  def error?
    check_resolved!
    !@error.nil?
  end
  
  
  # Get the subject.
  # 
  # @note
  #   Raises unless `@subject` has already been set, either at construction
  #   or via a successful {#resolve}. **Only use when you expect the subject
  #   to already be present** 
  # 
  # @return [::Object]
  # 
  # @raise [Resolution::UnresolvedError]
  #   When `@subject` has not been defined (see note).
  # 
  def subject
    check_resolved!
  
    unless @error.nil?
      raise NRSER::WrappedError.new \
        "Tried to access {#subject}, but subject instantiation caused an error",
        cause: @error
    end
    
    @subject
  end
  
  
  def error
    check_resolved!
    @error
  end
  
  
  
  # Set the {#subject}. Checks that it has not already been set and that it
  # conforms to {.subject_type}.
  # 
  # @param [::Object] subject
  # 
  # @return [::Object]
  #   `subject` parameter.
  # 
  # @raise [NRSER::Types::CheckError]
  #   If type check fails.
  # 
  def subject= subject
    if instance_variable_defined? :@subject
      raise NRSER::ConflictError.new \
        "Subject already set to", @subject,
        self: self
    end
    
    @subject = self.class.subject_type.check! subject
  end
  
  
  def error= error
    unless @error.nil?
      raise NRSER::ConflictError.new \
        "Error already set to", @error,
        self: self
    end
    
    unless error.is_a? Exception
      raise NRSER::TypeError.new \
        "`error` parameter must be an", Exception, "instance, found ", error
    end
    
    @error = error
  end
  
  
  # Resolve {#subject} against a {Hierarchy}, unless already {#resolved?}.
  # 
  # Details in {resolve_subject!} (which is called when {#resolved?} returns
  # `false`).
  # 
  # @param [Hierarchy] hierarchy
  #   Description hierarchy to resolve against.
  # 
  # @return [Base] self
  # 
  # @raise
  #   If there is an error 
  # 
  def resolve! hierarchy
    resolve_subject!( hierarchy ) unless resolved?
    self
  end
  
  
  # Is this description inside it's {#resolve_subject!} method?
  # 
  # We need to know when picking descriptions to attempt to resolve against
  # so we can avoid resolution loops.
  # 
  # @return [Boolean]
  # 
  def resolving?
    @resolving
  end
  
  
  # Has the {#subject} been resolved?
  # 
  # @return [Boolean]
  # 
  def resolved?
    @resolved
  end
  
  
  def check_resolved!
    raise Resolution::UnresolvedError.new( self: self ) unless resolved?
  end
  
  
  private
  # ========================================================================
    
    # Set the `@resolution`. It can only be set once. This sets the {#subject}
    # as well.
    # 
    # @private
    # 
    # @param [Resolution] resolution
    #   The resolution for this description's subject. Checked with 
    #   {RESOLUTION_TYPE}, which verifies it's class and that it's
    #   {Resolution#resolved?}.
    # 
    # @return [Resolution]
    #   The resolution.
    # 
    # @raise [NRSER::ConflictError]
    #   If `@resolution` is already set.
    # 
    # @raise (see #subject=)
    # 
    def resolution= resolution
      unless @resolution.nil?
        raise NRSER::ConflictError.new \
          "`@resolution` already set",
            current_resolution: @resolution,
            resolution_arg: resolution
      end
      
      RESOLUTION_TYPE.check! resolution
      
      if resolution.subject?
        self.subject = resolution.subject
      else
        self.error = resolution.error
      end
      
      @resolved = true
      @resolution = resolution
    end # #resolution=
      
    
    # Set `@subject` from the first successful {Resolution}.
    #
    # A {Resolution} is created for each {.from} entry, all referencing this
    # instance. 
    #
    # If any resolution is {Resolution#resolved?} from this instance's instance
    # variables, the {Resolution#subject} of first one (in order returned by
    # {.from}) is assigned to `@subject`.
    #
    # Otherwise, the described instances in {#each_ancestor} (if any) are
    # walked, and the first one to successfully {Resolution#resolved?} has it's
    # {Resolution#subject} assigned to `@subject`.
    #
    # If no {Resolution} resolves a {ResolutionError} is raised.
    # 
    # @private
    # 
    # @note
    #   Called in {#subject} to define `@subject` if needed so it can be
    #   returned.
    #   
    #   Either:
    #   
    #   1.  Sets `@subject` and `@resolution` variables **or**
    #   2.  Raises.
    #   
    #   Presumably only called once. However, **does *not* check that `@subject`
    #   and `@resolution` are 
    #
    #
    # @return [nil]
    #   When method has mutated `self` by setting `@subject` and `@resolution`.
    # 
    # @raise [Resolution::AllFailedError]
    #   When subject resolution fails.
    # 
    def resolve_subject! hierarchy
      # Protect from re-entry while resolving. This helps catching resolution
      # loops by being clear about what happen and providing a cleaner stack
      # trace than the stack overflow likely to happen otherwise.
      if resolving?
        raise NRSER::UnreachableError.new \
          "Subject resolution loop!",
          described: self
      end
      
      # Ensure around the rest of the the method to make sure we set 
      # `@resolving` to `false` when exiting.
      begin
        # Set the resolving flag so that neither this described nor any others
        # attempt to resolve from it while it is resolving.
        @resolving = true
        
        # Construct resolution instances for each of the {From} instances 
        # declared on the class
        resolutions = self.class.from.
          map { |from| Resolution.new from: from, described: self }
        
        # Set the resolution:
        # 
        # 1.  If any of the resolutions was already able to resolve, use that.
        # 2.  Otherwise, call {#update_until_resolved!} to update from the 
        #     description hierarchy or raise.
        # 
        self.resolution = \
          resolutions.find( &:resolved? ) ||
            update_until_resolved!( resolutions, hierarchy )
        
        nil
      ensure
        # Set `@resolving` to false when exiting the method regardless of
        # what happen
        @resolving = false
      end
    end # #resolve_subject!
    
    
    # For each {Described::Base} available, iterate over each of `resolutions`,
    # updating them from the {Described::Base}. As soon as a {Resolution} 
    # succeeds, return it. If none do, raise.
    # 
    # @private
    # 
    # @param [::Array<Resolution>] resolutions
    #   The {Resolution} instances to update and check for 
    #   {Resolution#resolved?}.
    # 
    # @return [Resolution]
    #   The first {Resolution#resolved?} instance.
    # 
    # @raise [Resolution::AllFailedError]
    #   When subject resolution fails.
    # 
    def update_until_resolved! resolutions, hierarchy
      hierarchy.
        # Skip any descriptions that are resolving - including ourself - 
        # because in order to resolve our subject, we will need to resolve
        # theirs too, and if they are resolving, using them can create a 
        # resolution loop
        reject( &:resolving? ).
        each { |described|
          resolutions.each { |resolution|
            resolution.update! described, hierarchy
            return resolution if resolution.resolved?
          }
        }
      
      # If we didn't find a successful resolution and return it then we
      # have failed
      raise Resolution::AllFailedError.new "Unable to resolve", self,
        resolutions: resolutions
    end # #update_until_resolved!
    
  public # end private *****************************************************
  
  
  # Language Integration Instance Methods
  # --------------------------------------------------------------------------
  
  def pretty_print pp
    pp.group(1, "{#{self.class}", "}") do
      pp.group(1, "<", ">") do
        self.class.subject_type.pretty_print pp
      end
      pp.breakable ' '
      pp.seplist(
        instance_variables.sort.
          map { |var_name|
            [ var_name.to_s[ 1..-1 ], instance_variable_get( var_name ) ]
          }.
          reject { |(name, value)|
            name != 'resolved' &&
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
  
end # class Base


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
