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

# Using {From} in {Base.from}
require_relative './from'

# Using {Resolution} in {Base#resolve_subject!}
require_relative './resolution'

# {Resolution#resolve_subject!} raises {Resolution::AllFailedError}
require_relative './resolution/all_failed_error'


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
  def self.from **types, &init_block
    @from ||= []
    
    if types.empty?
      unless init_block.nil?
        raise NRSER::ArgumentError.new \
          "Must provide `types` when declaring a {From}"
      end
      
      return @from
    end
    
    From.
      new(
        types: types,
        init_block: init_block,
      ).
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
  
  # The next described instance up the hierarchy from this one.
  # 
  # @return [nil]
  #   When this instance is a root.
  # 
  # @return [Base]
  #   When this instance is not a root.
  #     
  attr_reader :parent
  
  
  # Construction
  # ========================================================================
  
  # Instantiate a new `Base`.
  def initialize parent: nil, **kwds
    @parent = parent
    @resolved = nil
    
    if kwds.key? :subject
      self.subject = kwds[ :subject ]
      kwds.delete :subject
    end
    
    kwds.each do |name, value|
      instance_variable_set "@#{ name }", value
    end
  end # #initialize
  
  
  # Instance Methods
  # ========================================================================
  
  def find_by_human_name! human_name
    return self if self.class.human_names.include?( human_name )
    
    return parent.find_by_human_name!( human_name ) unless parent.nil?
    
    raise NRSER::NotFoundError.new \
      "Could not find described instance in parent tree with human name",
      human_name.inspect
  end
  
  
  def subject
    resolve_subject! unless instance_variable_defined? :@subject
    @subject
  end
  
  
  def subject= subject
    if instance_variable_defined? :@subject
      raise NRSER::ConflictError.new \
        "Subject already set to", @subject,
        self: self
    end
    
    @subject = self.class.subject_type.check! subject
  end
  
  
  def each_ancestor &block
    if block.nil?
      enum_for __method__
    elsif !parent.nil?
      yield parent
      parent.each_ancestor &block
    end
  end
  
  
  private
  # ========================================================================
    
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
    # 
    def resolve_subject!
      resolutions = self.class.from.
        map { |from| Resolution.new from: from, described: self }
      
      resolved = resolutions.find &:resolved?
      
      unless resolved.nil?
        return resolved_from_ivars
      end
      
      each_ancestor.find { |described|
        resolutions.find { |resolution|
          resolution.update! described
          resolved = resolution if resolution.resolved?
        }
      }
      
      if resolved.nil?
        raise Resolution::AllFailedError.new "Unable to resolve", self,
          resolutions: resolutions
      end
      
      @resolution = t.IsA( Resolution ).check! resolved
      self.subject = resolved.subject
      
      nil
    end # #resolve_subject!
    
  public # end private *****************************************************
  
  
end # class Base


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
