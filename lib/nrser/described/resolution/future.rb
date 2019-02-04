# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# {Candidate} is a {I8::Struct}
require 'i8/struct'

# Mixing in my custom pretty printing support
require "nrser/support/pp"


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  Described
class   Resolution


# Definitions
# =======================================================================

# Candidate = I8::Struct.new value: t.Top, source: t.NonEmptyString

# @todo document FutureValue class.
# 
class Future
  
  # Mixins
  # ==========================================================================
  
  # Mix in my custom pretty printing support
  include NRSER::Support::PP
  
  
  # Config
  # ============================================================================
  
  pretty_print_config \
    methods: { always: [ :described?, :fulfilled? ] }
  
  
  # Attributes
  # ==========================================================================
  
  # TODO document `method_name` attribute.
  # 
  # @return [attr_type]
  #     
  attr_reader :method_name
  
  
  # Construction
  # ==========================================================================
  
  # Instantiate a new `FutureValue`.
  def initialize **kwds
    if kwds.key? :described
      if kwds.key? :value
        raise ArgumentError.new \
          "Can't include `described:` and `value:` keywords!"
      end
      
      @described = \
        t.IsA( Described::Base ).check! kwds.delete( :described )
        
      @method_name = \
        t.In( Set[ :subject, :error ] ).check! kwds.delete( :method_name )
      
      if @described.resolved?
        @value = @described.public_send @method_name
      end
    else
      unless kwds.key? :value
        raise ArgumentError.new \
          "Must provide `described:` or `value:` keywords"
      end
      
      @value = kwds.delete :value
    end
    
    # @context = kwds
  end # #initialize
  
  
  # Instance Methods
  # ==========================================================================
  
  def described?
    instance_variable_defined? :@described
  end
  
  
  def described
    unless described?
      raise "This future has no `described`"
    end
    
    @described
  end
  
  
  def fulfilled?
    instance_variable_defined? :@value
  end
  
  alias_method :value?, :fulfilled?
  
  
  def value
    unless value?
      raise "This future has no `value` ({#fulfill!} it?)"
    end
    
    @value
  end
  
  
  def fulfill! hierarchy
    return self if value?
    
    @value = described.resolve!( hierarchy ).public_send method_name
  end
  
  
  # Language Integration Instance Methods
  # --------------------------------------------------------------------------
  
  def uniq_id
    return value if fulfilled?
    return described if described?
    self
  end
  
  
  def == other
    return false unless other.class == self.class
    
    # If both are resolved, compare by value
    return value == other.value if fulfilled? && other.fulfilled?
    
    # If both have descriptions, compare by those
    return described == other.described if described? && other.described?
    
    # Otherwise, they're not considered equal
    false
  end # #==
  
end # class Future


# /Namespace
# =======================================================================

end # class Resolution
end # module Described
end # module NRSER
