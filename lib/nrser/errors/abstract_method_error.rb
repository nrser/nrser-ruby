# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/log'
require 'nrser/core_ext/object/lazy_var'

require_relative './not_implemented_error'


# Namespace
# =======================================================================

module  NRSER


# Definitions
# =======================================================================

# Extension of Ruby's {NotImplementedError} to provide a useful message
# and convenient constructor for abstract methods.
# 
# This is a {NRSER::NicerError}.
# 
# @example
#   
#   def f
#     raise NRSER::AbstractMethodError.new( self, __method__ )
# 
# 
class AbstractMethodError < NotImplementedError
  
  # Mixins
  # ========================================================================
  
  # Be log!
  include NRSER::Log::Mixin
  
  
  # Attributes
  # ========================================================================
  
  # The abstract method's name that was called¹.
  # 
  # > ¹ I mean, that's what it *should* be, it's really just what was passed
  # >   as the `method_name:` keyword to {#initialize}.
  # 
  # @return [Symbol]
  #     
  attr_reader :method_name
  
  
  # TODO document `method_instance` attribute.
  # 
  # @return [Method]
  #     
  attr_reader :method_instance
  
  
  # TODO document `instance` attribute.
  # 
  # @return [attr_type]
  #     
  attr_reader :instance
  
  
  # Construct a new `AbstractMethodError`.
  # 
  # @param [Object] instance
  #   Instance that invoked the abstract method.
  # 
  # @param [Symbol | String] method_name
  #   Name of abstract method.
  # 
  def initialize instance, method_name
    @instance = instance
    @method_name = method_name
    @method_instance = instance.method @method_name
    
    super()
  end # #initialize
  
  
  def method_instance
    lazy_var :@method_instance do
      # Just drop a warning if we can't get the method object
      logger.catch.warn(
        "Failed to get method",
        instance: instance,
        method_name: method_name,
      ) do
        instance.method method_name
      end
    end
  end
  
  
  def method_owner
    lazy_var :@method_owner do
      method_instance && method_instance.owner
    end
  end
  
  
  def method_owner_name
    lazy_var :@method_owner_name do
      if method_owner
        method_owner.safe_name
      else
        '???'
      end
    end
  end
  
  
  def method_full_name
    lazy_var :@method_full_name do
      "#{ method_owner_name }##{ method_name.to_s }"
    end
  end
  
  
  def context
    {
      instance: instance,
      method_name: method_name,
    }
  end
  
  
  def default_message
    "Method ##{ method_name.to_s } is abstract"
  end
  
  
  def details
    @details ||= if method_owner == instance.class
      <<~END
        Method #{ method_full_name } is abstract, meaning
        #{ method_owner_name } is an abstract class and the invoking
        instance #{ instance } should NOT have been constructed.
      END
    else
      <<~END
        Method #{ method_full_name } is abstract and
        has not been implemented in invoking class #{ instance.class }.
        
        If you *are* developing the invoking class #{ instance.class } it
        (or a parent class between it and #{ method_owner_name }) must
        implement ##{ method_name.to_s }.
        
        If you *are not* developing #{ instance.class } it should be treated
        as an abstract base class and should NOT be constructed. You need to
        find a subclass of #{ instance.class } to instantiate or write
        your own.
      END
    end
  end
  
end # class AbstractMethodError


# /Namespace
# =======================================================================

end # module NRSER
