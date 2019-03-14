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

# Mixing in my custom pretty printing support
require "nrser/support/pp"

# {Base.Names} provides shortcut to {NRSER::Meta::Names}
require 'nrser/meta/names'

# Mixing in `Class#subclass?`
require 'nrser/ext/class/subclass'

# Using {Resolution} in {Base#resolve_subject!}
require_relative './resolution'

# {Resolution#resolve_subject!} raises {Resolution::AllFailedError}
require_relative './resolution/all_failed_error'

# {Resolution#resolve!} raises {Resolution::UnresolvedError}
require_relative './resolution/unresolved_error'

require_relative './errors/subject_type_error'


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

  # Constants
  # ========================================================================
  
  # The {Types::Type} of objects that can be set as {#resolution} - boils down
  # to {Resolution} instances that are {Resolution#resolved?}.
  # 
  # @todo
  #   Should also check that they describe this..?
  # 
  # @return [Types::Type]
  # 
  RESOLUTION_TYPE = t.IsA( Resolution ) & t.Attributes( :resolved? => true )
  

  # Mixins
  # ========================================================================
  
  include NRSER::Log::Mixin
  
  # Mix in my custom pretty printing support
  include NRSER::Support::PP
  
  # Mix in `Class#subclass?`
  extend NRSER::Ext::Class
  
  
  # Config
  # ==========================================================================
  
  pretty_print_config \
    ivars: {
      mode: :present,
      except: {
        :@resolved => :always,
      }
    }
  
  
  # Singleton Methods
  # ========================================================================
  
  # @overload subject_from
  #   Get the {SubjectFrom} instances for this description class,
  #   which represent the available ways to create {#subject} values for 
  #   this class' instances.
  #   
  #   @return [::Array<SubjectFrom>]
  #     The declared {SubjectFrom} instances for this class.
  # 
  # @overload subject_from **parameters, &block
  #   Declare a new way to create {#subject} values for instances of this class.
  #   
  #   @example
  #     class D < Described::Base
  #       
  #       subject_type ... # Type that `block` will return
  #       
  #       subject_from \
  #         object: Described::Object,
  #         name: ::String \
  #       do |object:, name:|
  #         # Create subject for {D} from `object` and `name`...
  #       end
  #       
  #       # ...
  #     end
  #   
  #   @param [::Hash<Symbol, Object>] parameters
  #     Essentially a keyword-name to type-spec map for what can be fed into 
  #     the `block` to produce a {#subject}.
  #     
  #     See {SubjectFrom#initialize} for details (this {::Hash} is just provided
  #     as it's `parameters:` keyword).
  #     
  #   @param [::Proc<**parameters -> SUBJECT>] block
  #     Block that accepts parameter keywords and values and returns a 
  #     {#subject} for instances of this class.
  #   
  #   @return [SubjectFrom]
  #     The new {SubjectFrom} instance.
  # 
  def self.subject_from **parameters, &block
    # Need to require here to prevent {Base} -> {From} -> {Base} loop
    require_relative './subject_from'
  
    @subject_from ||= []
    
    if parameters.empty?
      unless block.nil?
        raise NRSER::ArgumentError.new \
          "Must provide `name`/{SubjectFrom::Parameter} pairs when",
          "declaring a {SubjectFrom}"
      end
      
      return @subject_from
    end
    
    SubjectFrom.
      new( parameters: parameters, block: block, ).
      tap { |subject_from| @subject_from << subject_from }
  end
  
  
  # Get or declare the {Types::Type} of {#subject}s for instances of this class.
  # 
  # @overload .subject_type
  #   Get the {Types::Type} of {#subject}s for instances this class.
  #   
  #   @return [nil]
  #     No subject type declared.
  #   
  #   @return [Types::Type]
  #     This class' subject type.
  #   
  # @overload .subject_type type
  #   Declare the {Types::Type} of {#subject}s for instance of this class.
  #   
  #   This method is indented to be used durning subclass definition. Once
  #   the subject type has been set for a subclass, attempting to set it again
  #   will raise an error.
  #   
  #   @param [Object] type
  #     Type that instance's {#subject} must satisfy.
  #     
  #     If `type` is not a {Types::Type}, it will be made into one with 
  #     {Types.make}.
  #   
  #   @return [Type]
  #     The set type.
  # 
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
  
  
  # Support getting the {Types::Type} that {#error} will produce (companion to
  # {.subject_type}).
  # 
  # @todo
  #   Maybe this will be refine-able in the future, but for now just returns
  #   a {Types::IsA} around {::Exception} for all description classes.
  # 
  # @return [Types::Type]
  # 
  def self.error_type
    t.IsA ::Exception
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
  #   1.  The description didn't need to {#resolve!} because it was provided
  #       a {#subject} in {#initialize}.
  #       
  #   2.  The description has not been successfully {#resolve!}ed.
  # 
  # You can check {#resolved?} to tell what's up.
  # 
  # @return [Resolution]
  #   The resolution used to set {#subject}.
  #     
  attr_reader :resolution
  
  
  # Name/value map provided as keyword arguments at construction. Used as the
  # first place to look for values when {#resolve!}-ing.
  # 
  # @immutable Frozen
  # 
  # @return [::Hash<::Symbol, ::Object>]
  #     
  attr_reader :init_values
  
  
  # Construction
  # ========================================================================
  
  # Instantiate a new `Base`.
  # 
  # @overload initialize subject:
  #   Construct an instance that is already {#resolved?} to a {#subject}.
  #   
  #   @param [::Object] subject
  #     Value to set as the {#subject} (using {#subject=}).
  #   
  #   @raise [ArgumentError{subject: ::Object, other_kwds: ::Hash<Symbol, ::Object>}]
  #     If any keyword arguments besides `subject:` are passed.
  #   
  #   @raise [Types::CheckError]
  #     If `subject` doesn't satisfy {.subject_type}, see {#subject=}.
  # 
  # @overload subject **init_values
  #   Construct an instance with the provided {#init_values} to use during 
  #   resolution.
  #   
  #   @param [::Hash<::Symbol, ::Object>] init_values
  #     Name/value pairs to set as {#init_values}.
  # 
  def initialize **kwds
    @resolving = false
    @resolution = nil
    @resolved = false
    
    @error = nil
    
    if kwds.key? :subject
      self.subject = kwds[ :subject ]
      kwds.delete :subject
      
      unless kwds.empty?
        raise ArgumentError.new \
          "Can't provide additional keyword args with `subject:`",
          subject: subject,
          other_kwds: kwds
      end
      
      @resolved = true
    end
    
    @init_values = kwds.freeze
    
  end # #initialize
  
  
  # Instance Methods
  # ========================================================================
  
  # Does this instance have a {#subject}? 
  # 
  # @note
  #   Must be {#resolve!}-ed first, or this method will raise.
  # 
  # @return [Boolean]
  # 
  # @raise [Resolution::UnresolvedError]
  #   If this instance is not {#resolved?}.
  # 
  def subject?
    check_resolved!
    instance_variable_defined? :@subject
  end
  
  # Does this instance have an {#error}? 
  # 
  # @note
  #   Must be {#resolve!}-ed first, or this method will raise.
  # 
  # @return [Boolean]
  # 
  # @raise [Resolution::UnresolvedError]
  #   If this instance is not {#resolved?}.
  # 
  def error?
    check_resolved!
    !@error.nil?
  end
  
  
  # Get the resolved subject.
  # 
  # @note
  #   Must be {#resolve!}-ed first, or this method will raise.
  # 
  # @return [::Object]
  # 
  # @raise [Resolution::UnresolvedError]
  #   If this instance is not {#resolved?}.
  # 
  # @raise [WrappedError<::Exception>]
  #   If this instance resolved to an {#error} instead of a {#subject}, that
  #   {#error} will be wrapped and raised.
  # 
  def subject
    check_resolved!
  
    unless @error.nil?
      raise WrappedError.new \
        "Tried to access {#subject}, but subject instantiation caused an error",
        cause: @error
    end
    
    @subject
  end
  
  
  # Get the resolved error - the {::Exception} that was raised when 
  # instantiating the {#subject} during resolution (if any).
  # 
  # @note
  #   In particular, this is any error raised by calling {SubjectFrom#block}
  #   on the resolved {SubjectFrom} instance (which is always one of 
  #   {.subject_from}).
  #   
  #   These errors represent "expected errors" - those that happen when applying
  #   the operations that description instances describe, and hence are the
  #   errors that tests want to handle and verify.
  #   
  #   Errors that happen outside of that particular situation are errors in 
  #   the library logic or configuration, and do **not** become {#error} 
  #   values; they are generally allowed to bubble-up so the developer can 
  #   attend to them.
  # 
  # @note
  #   Must be {#resolve!}-ed first, or this method will raise.
  # 
  # @return [nil]
  #   This instance successfully resolved to a {#subject}.
  # 
  # @return [::Exception]
  #   The error raised 
  # 
  # @raise [Resolution::UnresolvedError]
  #   If this instance is not {#resolved?}.
  # 
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
  # @raise [ConflictError]
  #   If the subject has already been set.
  # 
  # @raise [Types::CheckError]
  #   If type check fails.
  # 
  def subject= subject
    if instance_variable_defined? :@subject
      raise ConflictError.new "Subject already set to", @subject, self: self
    end
    
    @subject = check_subject_type! subject
  end
  
  
  # Set the {#error}. Checks that it has not already been set and that it
  # conforms to {.error_type}.
  # 
  # @todo
  #   I'm not really sure *why* this is public, except that {#subject=} is...
  #   
  #   {#initialize} doesn't accept `error:`, and I don't know if it should or
  #   will.
  #   
  #   I don't think it's used outside of this file, and don't know why it would
  #   need to be...
  # 
  # @param [::Exception] error
  # 
  # @return [::Exception]
  #   `error` parameter.
  #
  # @raise [ConflictError]
  #   If the error has already been set.
  # 
  # @raise [Types::CheckError]
  #   If type check fails.
  # 
  def error= error
    unless @error.nil?
      raise ConflictError.new "Error already set to", @error, self: self
    end
    
    @error = self.class.error_type.check! error
  end
  
  
  # Resolve {#subject} or {#error} against a {Hierarchy}, unless already
  # {#resolved?}.
  #
  # Details...
  # --------------------------------------------------------------------------
  #
  # A {Resolution} is created for each {.subject_from} entry, all referencing
  # this instance. 
  #
  # If any resolution is {Resolution#resolved?} purely from this instance's
  # {#init_values}, the first one to do so (in order returned by
  # {.subject_from}) is assigned to {#resolution=}, causing it's
  # {Resolution#subject} or {Resolution#error} to become available as {#subject}
  # or #{error}, depending on if it's {SubjectFrom#block} succeeded or not.
  #
  # Otherwise, the described instances in `hierarchy` (if any) are walked,
  # and {Resolution#update!} is called on each {Resolution}, until a resolution
  # resolves, which is then sent to {#resolution=}, filling in {#subject} or
  # {#error} as mentioned above.
  #
  # If no {Resolution} resolves a {ResolutionError} is raised.
  # 
  # @param [Hierarchy] hierarchy
  #   Description hierarchy to resolve against.
  # 
  # @return [Base]
  #   Returns `self` for chaining.
  # 
  # @raise [Resolution::AllFailedError]
  #   When subject resolution fails.
  # 
  # @raise [UnreachableError]
  #   Inside the main block `@resolving` is set to `true`, and if the method is
  #   re-entered during this time an {UnreachableError} is raised.
  #   
  #   This helps catch resolution loops when developing and preventing stack 
  #   overflow by bailing out with a more descriptive error.
  # 
  def resolve! hierarchy
    return self if resolved?
    
    # Protect from re-entry while resolving. This helps catching resolution
    # loops by being clear about what happen and providing a cleaner stack
    # trace than the stack overflow likely to happen otherwise.
    if resolving?
      raise UnreachableError.new "Subject resolution loop!", described: self
    end
    
    # Ensure around the rest of the the method to make sure we set 
    # `@resolving` to `false` when exiting.
    begin
      # Set the resolving flag so that neither this described nor any others
      # attempt to resolve from it while it is resolving.
      @resolving = true
      
      # Construct resolution instances for each of the {From} instances 
      # declared on the class
      resolutions = self.class.subject_from.map { |subject_from|
        Resolution.new(
          subject_from: subject_from,
          described: self,
          hierarchy: hierarchy,
        )
      }
      
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
  
  
  # Check that this instance has been {#resolve!}-ed.
  # 
  # @return [nil]
  # 
  # @raise [Resolution::UnresolvedError]
  #   If this instance is not {#resolved?}.
  # 
  def check_resolved!
    raise Resolution::UnresolvedError.new( self: self ) unless resolved?
  end
  
  
  def check_subject_type! subject, resolution: nil
    self.class.subject_type.check! subject do
      raise SubjectTypeError.new \
        described: self,
        subject: subject,
        resolution: resolution
    end
  end
  
  
  # Language Integration Instance Methods
  # --------------------------------------------------------------------------
  
  def to_s
    class_name = self.class.name.sub /\ANRSER\:\:/, ''
    
    if resolved?
      if subject?
        "{#{ class_name } subject: #{ subject.to_s.truncate 32 }}"
      else
        "{#{ class_name } error: #{ error.to_s.truncate 32 }}"
      end
    else
      "{#{ class_name } init_values=#{ init_values.inspect.truncate 32 }}"
    end
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
            unless resolution.failed?
              resolution.update! described, hierarchy
              return resolution if resolution.resolved?
            end
          }
        }
      
      # If we didn't find a successful resolution and return it then we
      # have failed
      raise Resolution::AllFailedError.new "Unable to resolve", self,
        resolutions: resolutions
    end # #update_until_resolved!
    
  public # end private *****************************************************
  
end # class Base


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
