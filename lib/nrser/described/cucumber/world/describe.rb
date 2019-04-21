# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Using {::String#camelize}
require 'active_support/core_ext/string/inflections'

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/described'

require 'nrser/described/hierarchy/array'


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  World


# Definitions
# =======================================================================

# World mixins to manage the description hierarchy.
# 
# Mixed in to the "step classes" where steps are executed via 
# {Cucumber::Glue::DSL::World}.
# 
module Describe
  
  # Instance Methods
  # ========================================================================
  
  # @!group Accessing Descriptions Instance Methods
  # --------------------------------------------------------------------------
  
  # What's being described.
  # 
  # @return [nil]
  #   When nothing has been {#describe}'d yet.
  # 
  # @return [NRSER::Described::Base]
  #   The current description instance (youngest child in the description
  #   hierarchy).
  #   
  def described
    hierarchy.current
  end
  
  
  def hierarchy
    @hierarchy ||= Hierarchy::Array.new
  end
  
  alias_method :descriptions, :hierarchy
  
  
  def subject
    described.resolve!( hierarchy ).subject
  end
  
  
  # Is *lazy resolution* enabled for this scenario?
  # 
  # Read about it {file:lib/nrser/described/doc/lazy_resolution.md here}.
  # 
  # @return [Boolean]
  # 
  def lazy?
    @lazy
  end
  
  
  # Turn on *lazy resolution* for this scenario.
  # 
  # Read about it {file:lib/nrser/described/doc/lazy_resolution.md here}.
  # 
  def lazy!
    @lazy = true
  end
  
  
  # Construct a new described using the name of the class and keyword 
  # parameters and add it to the {#hierarchy}.
  # 
  # @note
  #   I think this is the preferred form of the method, as it will let me 
  #   thin out some of the `#describe_...` methods that don't do anything
  #   more than this.
  #   
  # @example
  #   describe :object, subject: "whatever"
  # 
  # @param [::String | ::Symbol] described_name
  #   Which class to construct.
  # 
  # @param [Hash<Symbol, Object>] kwds
  #   Keyword parameters to pass to the described class' constructor.
  #   
  #   Don't put `parent:` in here; it's added automatically.
  #   
  # @return [NRSER::Described::Base]
  #   Newly created and set {#described}.
  #   
  def describe described_name, **kwds
    NRSER::Described.
      const_get( described_name.to_s.camelize ).
      new( **kwds ).
      tap { |described|
        hierarchy.add described
        
        described.resolve!( hierarchy ) unless lazy?
      }
  end # #describe
  
  # @!endgroup Accessing Descriptions Instance Methods # *********************
  
  
  # @!group Describe Helper Instance Methods
  # --------------------------------------------------------------------------
  
  # Helper to intuitively describe singleton or instance methods by name.
  # 
  # @see NRSER::Described::Method
  # @see NRSER::Described::InstanceMethod
  # @see NRSER::Meta::Names::Method
  #
  # @param [#to_s] name
  #
  #   In simple terms, the method's name, which can be:
  #
  #   1.  "Bare", like `"f"`.
  #
  #   2.  "Implicitly" indicate that it is a singleton or instance method of
  #       whatever is already being described with `.` or `#` prefixes like
  #       `".f"` or `"#f"`.
  #
  #   3.  "Explicitly" identify a singleton method of a constant ({::Module},
  #       {::Class} or any old {::Object}) or an instance method of a {::Class}
  #       or {::Module} constant, like `"A::B.f"` or `"A::B#f"`.
  #
  #   In technical terms, an object with string representation (via `#to_s`)
  #   that conforms to the pattern of one of the concrete subclasses of
  #   {NRSER::Meta::Names::Method}.
  #
  # @return [NRSER::Described::Method | NRSER::Described::InstanceMethod]
  #   The newly created description instance.
  #
  # @raise [TypeError]
  #   If `name` does not match the pattern of one of the concrete subclasses
  #   of {NRSER::Meta::Names::Method}.
  #
  def describe_method name
    Meta::Names.match name,
      Meta::Names::Method::Explicit::Singleton, ->( method_name ) {
        const = resolve_const method_name.receiver_name
        method = const.method method_name.bare_name
        
        describe :method, subject: method
      },
      
      Meta::Names::Method::Explicit::Instance, ->( method_name ) {
        const = resolve_const method_name.receiver_name
        unbound_method = const.instance_method method_name.bare_name
        
        describe :instance_method, subject: unbound_method
      },
      
      Meta::Names::Method::Singleton, ->( method_name ) {
        describe :method, name: method_name.bare_name
      },
      
      Meta::Names::Method::Instance, ->( method_name ) {
        describe :instance_method, name: method_name.bare_name
      },
      
      Meta::Names::Method::Bare, ->( method_name ) {
        describe :method, name: method_name.bare_name
      }
  end # #describe_method
  
  
  # Helper to describe a single parameter's value by name.
  # 
  # If parameters are currently being described, adds this name and value
  # combination. Otherwise, creates a new {NRSER::Described::Arguments}
  # with this name and value set.
  # 
  # @example Set the value of a positional parameter
  #   describe_param 'a', 1
  # 
  # @example Set the value of a keyword parameter
  #   describe_param 'k:', 1
  # 
  # @example Set the value of the block paramter
  #   describe_param '&block', -> { 1 }
  # 
  # @see NRSER::Described::Arguments
  # @see NRSER::Meta::Names::Param
  # 
  # @param [#to_s] name
  #   The name of the parameter, in format to match the pattern of one of the 
  #   concrete subclasses of {NRSER::Meta::Names::Param}.
  # 
  # @param [::Object] value
  #   The parameter's value.
  # 
  # @return [NRSER::Described::Arguments]
  #   The parameters description instance the value was set in.
  # 
  # @raise [TypeError]
  #   If `name` does not match the pattern of one of the concrete subclasses
  #   of {NRSER::Meta::Names::Param}.
  # 
  def describe_param name, value
    if described.is_a? NRSER::Described::Arguments
      described[ name ] = value
      described
    else
      describe :arguments,
        subject: NRSER::Meta::Params::Named.new( named: { name => value } )
    end
  end # #describe_param
  
  
  # Construct a {Meta::Params} from positional argument values, taking account
  # of the last value potentially being a {Wrappers::Block} that indicates it
  # is the block parameter.
  # 
  # @param [::Array<::Object>] values
  #   Parameter values.
  # 
  # @return [Meta::Params]
  #   The new parameters object.
  # 
  def params_for_positional_values values
    # Handle the last entry being a `&...` expression, which is interpreted as 
    # the block parameter
    if values[ -1 ].is_a? Wrappers::Block
      args = values[ 0..-2 ]
      block = values[ -1 ]
    else
      args = values
      block = nil
    end
    
    Meta::Params::Simple.new *args, &block
  end # #params_for_positional_values
  
  
  # Describe parameters positionally, like you would using `#send`, accept that
  # the last value is passed as the block if it is a {Wrappers::Block}.
  # 
  # @param [::Array<::Object>] values
  #   Parameter values.
  # 
  # @return [NRSER::Described::Arguments]
  #   The parameters description.
  # 
  def describe_positional_params values
    describe :arguments,
      subject: params_for_positional_values( values )
  end # #describe_positional_params
  
  # @!endgroup Describe Helper Instance Methods # ****************************
  
end # module DescribeMixins


# /Namespace
# =======================================================================

end # module World
end # module Cucumber
end # module Described
end # module NRSER
