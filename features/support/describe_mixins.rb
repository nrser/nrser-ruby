# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/rspex/described'


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================


# Definitions
# =======================================================================

Described = NRSER::RSpex::Described

# @todo document DescribeMixins module.
# 
module DescribeMixins
  
  # Constants
  # ========================================================================
  
  # Shortcut to {NRSER::RSpex::Described}, making it less tiring to reference
  # those classes.
  # 
  # @todo
  #   This was a method but it didn't work form some reason..?
  # 
  # Described = NRSER::RSpex::Described
  # def Described; NRSER::RSpex::Described; end
  
  
  # Instance Methods
  # ========================================================================
  
  # Shortcut to {NRSER::Meta::Names}.
  # 
  # @return [::Module]
  # 
  def Names; NRSER::Meta::Names;  end
  
  
  # @!group Accessing {NRSER::RSpex::Described::Base} Instances
  # --------------------------------------------------------------------------
  
  def described
    @described
  end
  
  
  def describe described
    @described = t.check! described, Described::Base
  end
  
  # @!endgroup Accessing {NRSER::RSpex::Described::Base} Instances # *********
  
  
  def expect_it
    expect described.subject
  end
  
  
  def expect_described human_name
    expect described.find_by_human_name!( human_name ).subject
  end
  
  
  def value_for raw_string
    if expr? raw_string
      eval backtick_unquote( raw_string )
    else
      raise NotImplementedError,
            "TODO can only handle expr strings so far, found #{ raw_string.inspect }"
    end
  end
  
  
  def describe_class class_name
    describe Described::Class.new \
      parent: described,
      subject: resolve_class( class_name )
  end
  
  
  def describe_module module_name
    describe Described::Module.new \
      parent: described,
      subject: resolve_module( module_name )
  end
  
  
  def describe_method identifier
    Names.match identifier,
      Names::QualifiedSingletonMethod, ->( name ) {
        const = resolve_module name.module_name
        method = const.method name.method_name
        
        describe Described::Method.new \
          parent: described,
          subject: method
      },
      
      Names::QualifiedInstanceMethod, ->( name ) {
        cls = resolve_class name.module_name
        unbound_method = cls.instance_method name.method_name
        
        describe Described::InstanceMethod.new \
          parent: described,
          subject: unbound_method
      },
      
      Names::SingletonMethod, ->( name ) {
        describe Described::Method.new \
          parent: described,
          name: name.method_name
      },
      
      NRSER::Meta::Names::InstanceMethod, ->( name ) {
        describe Described::InstanceMethod.new \
          parent: described,
          name: name.method_name
      },
      
      NRSER::Meta::Names::Method, ->( name ) {
        describe Described::Method.new \
          parent: described,
          name: name
      }
  end
  
  
  def describe_response **kwds
    describe Described::Response.new \
      parent: described,
      **kwds
  end
  
  
  def describe_param name, value
    if described.is_a? Described::Parameters
      described[ name ] = value
    else
      describe Described::Parameters.new \
        parent: described,
        subject: NRSER::Meta::Params.new( named: { name => value } )
    end
  end
  
  
  def describe_params *args, **kwds, &block
    describe Described::Parameters.new \
      parent: described,
      subject: NRSER::Meta::Params.new( args: args, kwds: kwds, block: block )
  end
  
end # module DescribeMixins

# /Namespace
# =======================================================================
