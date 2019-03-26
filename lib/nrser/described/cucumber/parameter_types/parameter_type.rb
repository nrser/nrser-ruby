# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# ----------------------------------------------------------------------------

require 'set'

# Deps
# ----------------------------------------------------------------------------

# Extending {::Cucumber::CucumberExpressions::ParameterType} with our own
require 'cucumber/cucumber_expressions/parameter_type'

# Project / Package
# -----------------------------------------------------------------------

# Need to deal with tokens
require 'nrser/described/cucumber/tokens'

# Using {Wrappers::String::Match} to flag parameter matches that are *not*
# tokens (just general regular expressions)
require 'nrser/described/cucumber/wrappers'


# Refinements
# =======================================================================

require 'nrser/refinements/regexps'
using NRSER::Regexps

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  ParameterTypes


# Definitions
# =======================================================================

# @todo document ParameterType class.
class ParameterType < ::Cucumber::CucumberExpressions::ParameterType
  
  # Constants
  # ========================================================================
  
  DEFAULT_TRANSFORMER = ->( *group_tokens ) {
    if group_tokens.length == 1
      group_tokens[ 0 ]
    else
      group_tokens
    end
  }
  
  
  # Singleton Methods
  # ========================================================================
  
  
  # Attributes
  # ========================================================================
  
  # Array-ification of the `patterns:` that the instance was constructed with.
  # 
  # @return [::Array<::Object>]
  #     
  attr_reader :patterns
  
  
  # Entries in {#patterns} that are {Tokens::Token} subclasses, as well as all
  # those from any {ParameterType} instances in {#patterns}.
  # 
  # @return [::Array<::Tokens::Token>]
  #     
  attr_reader :token_classes
  
  
  # When the `transformer:` keyword provided to {#initialize} is a {::Symbol},
  # that means to call that method on the {Tokens::Token} instances created in
  # {#transform} to complete the transformation.
  #
  # This is used a shortcut for the many parameter types that want to use
  # {Tokens::Token#unquote} or {Tokens::Token#to_value} to get the object to
  # provide to their steps.
  #
  # When `transformer:` is a {::Symbol}, this instance variable will be set to
  # that symbol as a record of how the parameter type is configured, since the
  # `@transformer` value will be set to the actual {::Proc} needed to do the
  # dirty work.
  #
  # Otherwise, this will stay `nil`.
  #
  # @return [nil]
  #   A {#transformer} {::Proc} was either explicitly provided or the default
  #   {IDENTITY} was used at construction.
  #
  # @return [::Symbol]
  #   This symbol was provided for the `transformer:` keyword
  #   at construction, and the {#transformer} {::Proc} was generated
  #   automatically (see {#init_transformer!}).
  #
  attr_reader :transformer_token_method_name
  
  
  # Though `@transformer` is a part of the 
  # {::Cucumber::CucumberExpressions::ParameterType} superclass, that class does
  # not define an attribute reader for it.
  # 
  # So we do. Because it may be useful for us from steps that are processing
  # table values that did not pass through a parameter type transformation.
  # 
  # @return [::Proc]
  #     
  attr_reader :transformer
  
  
  # Construction
  # ========================================================================
  
  # Instantiate a new `ParameterType`.
  # 
  # @note
  #   I'm assuming that {#type} must be a {::Class}. The 
  #   [Custom Parameter Types][] documentation is not specific, it just says
  #   
  #   > The return type of the transformer block.
  #   
  #   and it's not clear to me where/how/if the type is actually used.
  #   
  #   I haven't given it a ton of thought, but I don't immediately see any 
  #   reason that a non-class {::Module} couldn't be used like an interface,
  #   specifying that all return values include it, but that would considerably
  #   complicate {#init_generate_type}.
  #   
  #   [Custom Parameter Types]: https://docs.cucumber.io/cucumber/cucumber-expressions/#custom-parameter-types
  # 
  # @param [nil | ::Class] type
  #   Either:
  #   
  #   1.  The {::Class} that all transformed values will be instances of.
  #       
  #   2.  `nil`, in which case the type will be deduced from the `patterns:`
  #       and the `transformer:`. Not allowed if a {::Proc} is being provided
  #       for `transformer:`, since we have no way of figuring out what it
  #       will return.
  # 
  # @param [::Proc | ::Symbol] transformer
  #   What to do to the matched strings before passing them to the step, 
  #   *in addition* to (and after) wrapping them in {Tokens::Token} instances.
  #   
  #   When a {::Proc} is provided, it is `#instance_exec`'d in the scenario 
  #   instance, and provided a the matched tokens as splatted (`*`) positional
  #   arguments.
  #   
  #   When a {::Symbol} is provided, it is interpreted as the name of an 
  #   instance method on {Tokens::Token} to call on each matched token to create
  #   the final transformed value, and a `transformer:` {::Proc} generated
  #   to properly handle matches.
  #   
  #   `:unquote` and `:to_value` should be supported for all {Tokens::Token},
  #   and {Tokens::Token} subclasses may define methods to support additional
  #   transformations ({Tokens::Const} does so with `:to_class` and 
  #   `:to_module`).
  #   
  #   See
  #   {file:lib/nrser/described/cucumber/parameter_types/doc/parameter_type/generated_transformers.md}
  #   for detailed information.
  #   
  #  
  def initialize  name:,
                  patterns:,
                  type: nil,
                  transformer: DEFAULT_TRANSFORMER,
                  use_for_snippets: true,
                  prefer_for_regexp_match: false
    
    # Initialize relevant instance variables from `patterns:`, returning the
    # {::Array} of regular expression source string that we need to pass to 
    # {::Cucumber::CucumberExpressions::ParameterType#initialize}
    regexp_sources = init_patterns! patterns
    
    # Type check `transformer:` keyword, generating a {::Proc} for it if it's
    # a {::Symbol}
    transformer = init_transformer! transformer
    
    
    type = init_type type, transformer
    
    super(
      name.to_s,
      regexp_sources,
      type,
      transformer,
      use_for_snippets,
      prefer_for_regexp_match
    )
  end # #initialize
  
  
  private # @!group Initialization Helper Instance Methods
  # --------------------------------------------------------------------------
    
    def init_patterns! patterns_kwd
      # Cast the `patterns:` keyword parameter value to an {::Array} and save
      # a copy of it. This will be useful for debugging at the least.
      @patterns = Array( patterns_kwd ).dup.freeze
      
      # List of {Tokens::Token} subclasses that this parameter type matches,
      # including any from any other {ParameterType} instances provided as
      # patterns
      @token_classes = []
      
      # A list of patterns that are not tokens or other parameter types.
      # I had this in initially but decided to scrap it since it can be obtained
      # by filtering `@patterns`
      # @other_patterns = []
      
      # List of all regular expression {::String} sources to pass up to 
      # {::Cucumber::CucumberExpressions::ParameterType#initialize}, which we
      # *return* so that our {#initialize} can pass it to `super()`
      regexp_sources = []
      
      @patterns.each do |obj|
        if Tokens::Token.subclass? obj
          # Subclasses of {Tokens::Token}, which are appended to
          # `@token_classes` (preserving their order) and have the fragment
          # source of their pattern extracted for the regular expression (since
          # {::Cucumber::CucumberExpressions::ParameterType} translates
          # {::Regexp} to their string sources anyways, so might as well do so
          # here).
          
          @token_classes << obj
          regexp_sources << obj.pattern.to_fragment_source
          
        elsif obj.is_a? ParameterType
          @token_classes.push *obj.token_classes
          regexp_sources.push *obj.regexps
          
        else
          # @other_patterns << obj
          regexp_sources << re.to_fragment_source( obj )
          
        end
      end # @patterns.each
      
      @token_classes.freeze
      @referenced_parameter_types.freeze
      @other_patterns.freeze
      
      regexp_sources
    end # #init_patterns!
    
    
    # Generate a {#transformer} value given the name of a instance method on
    # {Tokens::Token} to use for the transformation.
    #
    # @param [::Symbol] token_method_name
    #   The name of the instance method on {Tokens::Token} to call for 
    #   transformation. 
    #
    # @return [::Proc<(*Tokens::Token)=>(::Array<self.type>|self.type)> ]
    #   The {::Proc} for {#transformer}, which is assigned through {#initialize}
    #   passing it up to 
    #   {::Cucumber::CucumberExpressions::ParameterType#initialize}.
    #   
    #   The proc will be `#instance_exec`'d in the scenario instance (called
    #   `self_obj` in 
    #   {::Cucumber::CucumberExpressions::ParameterType#transform}), and maps
    #   a either:
    #   
    #   1.  A single {Tokens::Token} to a single instance of {#type}, or
    #   2.  a splattering of two or more {Tokens::Token} instance to a 
    #       corresponding {::Array} of {#type} instances.
    #
    def init_generate_token_method_transformer! token_method_name
      # I *think* we need the local var version so that the value is captured
      # in the transformer {::Proc}, which is executed with `#instance_exec`
      # inside the scenario instance (called `self_obj` in
      @transformer_token_method_name  = \
        transformer_token_method_name = token_method_name
      
      ->( *group_tokens ) {
        transformed = group_tokens.map { |token|
          method = token.method transformer_token_method_name
          
          if method.arity == 0
            method.call
          else
            method.call self
          end
        }
        
        if transformed.length == 1
          transformed.first
        else
          transformed
        end
      }
    end # #generate_token_method_transformer
    
    
    # @todo Document init_transformer! method.
    # 
    # @param [type] arg_name
    #   @todo Add name param description.
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def init_transformer! transformer_kwd
      # If `transformer_kwd` is a {::Symbol}, it will be assigned here. See
      # {#transformer_token_method_name} for semi-gory details.
      @transformer_token_method_name = nil
      
      t.match transformer_kwd,
        t.NonEmptySymbol,
          method( :init_generate_token_method_transformer! ),
        ::Proc,
          # WARNING Because `transformer_kwd` is a {::Proc}, can't reference it
          #         by value here... it would be invoked! Must provide a
          #         {::Proc} that returns it.
          -> { transformer_kwd }
    end # #init_transformer!
    
    
    # Generate the {Cucumber::CucumberExpressions::ParameterType#type} 
    # attribute (which is a {::Class}) based on the {#token_classes} this
    # {ParameterType} matches.
    # 
    # This method is called during initialization when the `type:` keyword 
    # argument is *not* given to {#initialize}.
    # 
    # From what I remember, it's not totally clear what the type information
    # is used by Cucumber for, but it seems pertinent to provide it.
    # 
    # There are some additional details here:
    # {file:lib/nrser/described/cucumber/parameter_types/doc/parameter_type/generated_transformers.md#Optional_Support_for_Automatic_type__Resolution
    # Optional Support for Automatic type: Resolution}.
    # 
    # Restriction: Must use {DEFAULT_TRANSFORMER}
    # ------------------------------------------------------------------------
    # 
    # The {ParameterType} **must** be using the {DEFAULT_TRANSFORMER} as its
    # {#transformer} - otherwise we can't really have any idea what class of
    # object it will return.
    # 
    # This is fact the only reason we need the `transformer` parameter - to 
    # check that it is {DEFAULT_TRANSFORMER}. An {ArgumentError} will be raised
    # if it's not.
    # 
    # @param [::Proc] transformer
    #   The user-level transformer this {ParameterType} will use. Only here to
    #   check that it is {DEFAULT_TRANSFORMER}.
    # 
    # @return [::Class]
    #   The type to use.
    # 
    # @raise [NRSER::ArgumentError]
    #   If a {::Proc} was provided for the `transformer:` keyword to 
    #   {#initialize}, since at that point we have no idea what it will return,
    #   and need `type:` to have been provided as well.
    # 
    def init_generate_type transformer
      token_type_getter = if transformer_token_method_name.nil?
        # Need to check that we're using the {DEFAULT_TRANSFORMER}, otherwise
        # we have no idea what it will return and we **need** a `type:`
        # keyword to be provided
        unless transformer == DEFAULT_TRANSFORMER
          raise NRSER::ArgumentError.new \
            "When providing a custom `transformer:` {::Proc} you **MUST**",
            "provide a `type:` keyword as well"
        end
        
        ->( token_class ) { token_class }
      else
        "#{ transformer_token_method_name }_type".to_sym.to_proc
      end
      
      token_transform_types = token_classes.map( &token_type_getter ).to_set
      
      unless other_patterns.empty?
        token_transform_types << Tokens::Other
      end
      
      # "Last common ancestor" in basically a one-liner... Hot damn Ruby.
      token_transform_types.
        map { |cls| cls.ancestors.select { |mod| mod.is_a? ::Class }.to_set }.
        reduce( :& ).
        min
    end # #init_generate_type
    
    
    # @todo Document init_type! method.
    # 
    # @param [type] arg_name
    #   @todo Add name param description.
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def init_type type_kwd, transformer
      t.match type_kwd,
        t.Nil,
          -> { init_generate_type transformer },
        ::Class,
          type_kwd
    end # #init_type!
  
  public # @!endgroup Initialization Helper Instance Methods # ***************
  
  
  # Instance Methods
  # ========================================================================
  
  def other_patterns
    @other_patterns ||= patterns.flat_map { |pattern|
      if Tokens::Token.subclass? pattern
        []
      elsif pattern.is_a? ParameterType
        pattern.other_patterns
      else
        pattern
      end
    }
  end
  
  
  def transform self_obj, group_values
    group_tokens = group_values.map { |group_value|
      token_class = @token_classes.find { |token_class|
        token_class.pattern =~ group_value
      }
      
      if token_class.nil?
        Tokens::Other.new group_value
      else
        token_class.from group_value
      end
    }
    
    super( self_obj, group_tokens )
  end
  
  
  def =~ string
    to_re =~ string
  end
  
  
  def match *args
    to_re.match *args
  end
  
  
  def to_re
    @composed_regexp ||= re.or *regexps
  end
  
  
end # class ParameterType


# /Namespace
# =======================================================================

end # module ParameterTypes
end # module Cucumber
end # module Described
end # module NRSER
