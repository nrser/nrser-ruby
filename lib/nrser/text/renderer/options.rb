# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Stdlib ###

### Deps ###

require 'active_support/ordered_hash'

### Project / Package ###

require 'nrser/support/critical_code'


# Refinements
# =======================================================================


# Namespace
# =======================================================================

module  NRSER
module  Text
class   Renderer


# Definitions
# =======================================================================

# 
# 
# @immutable Frozen 
# 
# You can view all Cucumber features for the module here: 
# {requirements::features::lib::nrser::text::renderer::options Features}
# 
# Both YARD examples and Cucumber features are verified programmatically, with 
# results on the [Travis CI site][].
# 
# [Travis CI site]: https://travis-ci.org/nrser/nrser.rb
# 
class Options
  
  # Constants
  # ==========================================================================
  
  # The weird stuff that can happen if it's too low, and it's got to be a 
  # mistake at that point... right?
  # 
  # @return [::Integer]
  # 
  WORD_WRAP_MIN = 24
  
  
  # @!group Instance Default Constants
  # --------------------------------------------------------------------------
  
  # Default characters to use for {#no_preceding_space_chars}, which is used to
  # form {#no_preceding_space_regexp}.
  # 
  # @return [::Array<::String>]
  # 
  DEFAULT_NO_PRECEDING_SPACE_CHARS = %w(, ; : . ? !).freeze
  
  
  # Default {#header_depth}.
  # 
  # @return [Integer]
  #   Non-negative.
  # 
  DEFAULT_HEADER_DEPTH = 0
  
  
  # Default {#list_indent}.
  # 
  # @return [Integer]
  # 
  DEFAULT_LIST_INDENT = 4
  
  
  # Default {#list_header_depth}.
  # 
  # @return [Integer]
  #   Non-negative.
  # 
  DEFAULT_LIST_HEADER_DEPTH = 3
  
  
  # Wrap lines by word-splitting at a column?
  # 
  # @return [false]
  #   Disable word-wrapping.
  # 
  # @return [::Integer]
  #   Column number to wrap lines at. Must be larger than {WORD_WRAP_MIN}.
  # 
  DEFAULT_WORD_WRAP = false
  
  
  # Default amount of spaces to indent {Tag::Code} blocks.
  # 
  # @return [::Integer]
  # 
  DEFAULT_CODE_INDENT = 4
  
  
  # Default newline termination behavior.
  # 
  # @return [::Symbol | Boolean]
  # 
  DEFAULT_NEWLINE_TERMINATE = :detect
  
  # @!endgroup Instance Default Constants # **********************************
  
  
  # Mixins
  # ==========================================================================
  
  # Make critical code methods available in both singleton and instances.
  extend  Support::CriticalCode
  include Support::CriticalCode
  
  
  # Singleton Methods
  # ==========================================================================
  
  def self.from options
    case options
    when nil
      new
    when Options
      options
    when ::Hash
      new options
    else
      raise ::TypeError,
        "Expected `nil`, #{ self } or {Hash}, found #{ options.class }: " +
        options.inspect
    end
  end
  
  
  # @!group Dynamic Defaults Singleton Methods
  # --------------------------------------------------------------------------
  
  # Default for {#color?}, looks first for an {ENV} var, then guesses about the
  # terminal using some code I got from Thor.
  # 
  # {ENV} var is `NRSER_TEXT_USE_COLOR`.
  # 
  # @return [Boolean]
  # 
  def self.default_color?
    Support::CriticalCode.env? 'NRSER_TEXT_USE_COLOR',
      # Detect based on environment
      # 
      # Borrowed from Thor (MIT license)
      # 
      # https://github.com/erikhuda/thor/blob/0887bc8fb257fadf656fb4c4f081a9067b373e7b/lib/thor/shell.rb#L14
      # 
      default: !(
        RbConfig::CONFIG["host_os"] =~ /mswin|mingw/ &&
        !ENV["ANSICON"]
      )
  end # .default_color?
  
  # @!endgroup Dynamic Defaults Singleton Methods # **************************
  
  
  # Get a {::Proc} to use as the `&block` argument to {.def_option}.
  # 
  # @param [#to_s] name
  #   Name of the option to use in any validation error messages.
  # 
  # @return [::Proc<(::Object, ::Object) ⇒ ::Object>]
  #   Accepts `(arg, default)` and returns `arg` if is an {::Integer} and
  #   non-negative (greater or equal to `0`). Otherwise, raises.
  # 
  def self.non_negative_integer_option_block_for name
    ->( arg, default ) do
      unless arg.is_a?( ::Integer )
        raise ::TypeError,
          "Expected `#{ name }` option to be an {Integer}, " +
          "given {#{ arg.class }}: #{ arg.inspect }"
      end
      
      unless arg >= 0
        raise ::ArgumentError,
          "Expected `#{ name }` option to be 0 or greater, " +
          "given #{ arg }"
      end
      
      arg
    end
  end # .non_negative_integer_option_block_for
  
  
  def self.normalize_name name
    case name
    when ::Symbol
      name
    when ::String
      name.to_sym
    else
      nil
    end
  end
  
  
  def self.normalize_name! name
    normalize_name( name ).tap do |name_sym_or_nil|
      if name_sym_or_nil.nil?
        raise ::TypeError,
          "Expected {Symbol} or {String}, given {#{ name.class }}: " +
          name.inspect
      end
    end
  end
  
  
  def self.option_defs
    # Make sure the hash is initialized
    @option_defs ||= ActiveSupport::OrderedHash.new
  end
  
  private_class_method :option_defs
  
  
  def self.def_option name, default:, boolean: false, &block
    # We want symbol names
    name = name.to_sym unless name.is_a?( ::Symbol )
    
    # Puke if this class already has an option with that name. A superclass
    # could still have one of the same name that this overrides, we cool with
    # that for the moment.
    if option_defs.key? name
      raise ::KeyError, "Option `#{ name }` already exists in {#{ self }}"
    end
    
    # Setup the structure
    option_defs[ name ] = {
      name: name,
      default: default,
      block: block,
      defined_in: self,
    }.freeze
    
    # Setup the method
    
    method_name = if boolean then "#{ name }?" else name end
    ivar_name = "@#{ name }"
    
    define_method method_name do
      self[ name ]
    end
    
    nil
  end # .def_option
  
  
  def self.get_option_def name
    name = normalize_name! name
    
    if option_defs.key? name
      option_defs[ name ]
    elsif superclass && superclass <= Options
      superclass.get_option_def name
    else
      nil
    end
  end
  
  
  def self.get_option_def! name
    get_option_def( name ).tap do |option_def_or_nil|
      if option_def_or_nil.nil?
        raise ::KeyError, "Option #{ name } does not exist"
      end
    end
  end
  
  
  def self.each_option_def &block
    if block.nil?
      enum_for __method__
    else
      if superclass && superclass <= Options
        superclass.each_option &block
      end
      option_defs.values.each &block
    end
  end
  
  
  # Options
  # ==========================================================================
  
  def_option  :word_wrap,
              default: DEFAULT_WORD_WRAP do |arg, default|
    case arg
    when nil
      default
      
    when false
      false
      
    when ::Integer
      if arg < WORD_WRAP_MIN
        raise ::ArgumentError,
          "`word_wrap` option must be #{ WORD_WRAP_MIN } or greater, " +
          "given #{ arg }"
      end
      
      arg
    else
      raise ::TypeError,
        "`word_wrap` option must be `nil`, `false` or an {Integer}, " +
        "given #{ arg.inspect }"
        
    end # case arg
  end # option :word_wrap
  
  
  def_option  :no_preceding_space_chars,
              default: DEFAULT_NO_PRECEDING_SPACE_CHARS do |arg, default|
    unless arg.is_a? ::Array
      raise ::TypeError,
        "`no_preceding_space_chars` option must be an {Array}, " +
        "given {#{ arg.class }}: #{ arg.inspect }"
    end
    
    arg.map { |entry|
      unless entry.is_a? ::String
        # NOTE  Can't use {NRSER::TypeError} 'cause it uses text stuff to 
        #       render! See note in class doc-string.
        raise ::TypeError,
          "Entries in `no_preceding_space_chars:` must be {String}s," +
          "given #{ entry.class }: #{ entry.inspect }"
      end
      
      entry.freeze
    }.freeze
  end # option :no_preceding_space_chars
  
  
  def_option  :color,
              default: default_color?,
              boolean: true do |arg, default|
    !!arg
  end
  
  
  def_option :header_depth, default: DEFAULT_HEADER_DEPTH,
    &non_negative_integer_option_block_for( :header_depth )
  
  
  def_option :list_indent, default: DEFAULT_LIST_INDENT,
    &non_negative_integer_option_block_for( :list_indent )
  
  
  def_option :list_header_depth, default: DEFAULT_LIST_HEADER_DEPTH,
    &non_negative_integer_option_block_for( :list_header_depth )
  
  
  def_option :code_indent, default: DEFAULT_CODE_INDENT,
    &non_negative_integer_option_block_for( :list_header_depth )
  
  
  def_option :newline_terminate, default: DEFAULT_NEWLINE_TERMINATE \
  do |arg, default|
    case arg
    # when nil
    #   default
    when :detect, true, false
      arg
    else
      raise ::TypeError,
        "Expected `newline_terminate` to be `:detect`, `true` or `false`, " +
        "found #{ arg.class }: #{ arg.inspect }"
    end
  end
  
  
  def_option :join_with, default: ' ' do |arg, default|
    unless arg.is_a? ::String
      raise ::TypeError,
        "Expected `join_with` to be a {String}, " +
        "found #{ arg.class }: #{ arg.inspect }"
    end
  end
  
  
  # Construction
  # ==========================================================================
  
  # Instantiate a new `Options`.
  # 
  # @param [::Hash<::Symbol, ::Object>] options
  #   Option names mapped to value.
  # 
  # @raise
  #   If `options` names don't exist or values aren't valid and 
  #   {Support::CriticalCode.enabled?} is false.
  # 
  def initialize options = {}
    delta( options ).each do |name, value|
      instance_variable_set "@#{ name }", value
    end
    
    freeze
  end # #initialize
  
  
  # Instance Methods
  # ==========================================================================
  
  # Regular expression to test against the right-hand side (RHS) {::String} of
  # a {.join} to see if we should omit the separating space character.
  # 
  # Basically, does the RHS start with a punctuation character that should *not*
  # have a space in front of it?
  # 
  # This is all English-only at the moment.
  # 
  # @return [Regexp]
  #   
  def no_preceding_space_regexp
    /\A[#{ Regexp.escape no_preceding_space_chars.join }](?:[[:space:]]|$)/
  end
  
  
  # @!group Read Instance Methods
  # --------------------------------------------------------------------------
  
  # Get an option value by name.
  # 
  # @param [::Symbol | ::String] name
  #   Name of the option.
  # 
  # @param [Boolean] raise_when_missing
  #   When true, a {::KeyError} will be raised if `name` is not an option name
  #   (instead of returning `nil`).
  #   
  #   Note that {#get!} is short-hand for calling this method with this option
  #   true.
  # 
  # @return [nil]
  #   There is no `name` option *and* `raise_when_missing:` is false.
  # 
  # @return [::Object]
  #   The option value (or default).
  # 
  # @raise [::KeyError]
  #   When `name` is not an option name *and* `raise_when_missing:` is true.
  # 
  def get name, raise_when_missing: false
    ivar_name = "@#{ name }"
    
    if instance_variable_defined? ivar_name
      instance_variable_get ivar_name
    else
      option_def = self.class.get_option_def name
      
      if option_def.nil?
        if raise_when_missing
          raise ::KeyError, "Option #{ name } does not exist"
        else
          nil
        end
      else
        option_def[ :default ]
      end
    end
  end # #get
  
  alias_method :[], :get
  
  
  # Get an option value, raising if the name does not exist.
  # 
  # @param [::Symbol | ::String] name
  #   Name of the option.
  # 
  # @return [::Object]
  #   The option value (or default).
  # 
  # @raise [::KeyError]
  #   When `name` is not an option name.
  # 
  def get! name
    get name, raise_when_missing: true
  end
  
  # @!endgroup Read Instance Methods # ***************************************
  
  
  # @!group Merging Instance Methods
  # --------------------------------------------------------------------------
  
  protected
  # ========================================================================
    
    def derive &setup
      new_options = self.class.allocate
      instance_variables.each do |ivar_name|
        new_options.instance_variable_set ivar_name,
                                          instance_variable_get( ivar_name )
      end
      setup.call new_options
      new_options.freeze
    end
    
  public # end protected ***************************************************
  
  # Compute the difference between a {::Hash} of option names and values and
  # what is defined in the instance.
  #
  # This is important for figuring out *if* we need to create a new instance to
  # realize those options, and is used for such in {#merge}.
  #
  # As part of figuring that out, this method normalizes the names (with
  # {.normalize_name!}) and passes the values through the corresponding option's
  # processing block.
  #
  # The {::Hash} you get back has only valid names and values, and only for
  # options whose values differ from the ones in this instance.
  # 
  # @param [::Hash<(::Symbol | ::String), ::Object>] hash
  #   {::Hash} of option names ({::Symbol} or {::String} please) to values.
  # 
  # @return [::Hash<::Symbol, ::Object>]
  #   {::Hash} of names to values for options that differ from those in this
  #   instance.
  #   
  #   Names are all normalized, and values are all validated.
  #
  # @raise
  #   Many things can go wrong in here... bad names, bad values. Handling of
  #   *each* option pair in `hash` is wrapped by 
  #   {Support::CriticalCode#try_critical_code}.
  #   
  #   If {Support::CriticalCode.enabled?} is true, then any errors that could 
  #   reasonably be caused by argument data should be downgraded to warnings,
  #   and those options omitted from the returned {::Hash}.
  #   
  #   When {Support::CriticalCode.enabled?} is false, errors will be raised as
  #   usual.
  #   
  #   Additional details of how the critical code system works and what it 
  #   catches are available in the {Support::CriticalCode} documentation.
  #
  def delta hash
    hash.each_with_object( {} ) do |(name, given_value), delta|
      try_critical_code do
        
        name_sym = self.class.normalize_name! name
        
        current_value = get! name_sym
        
        if given_value != current_value
          option_def = self.class.get_option_def! name_sym
          new_value = option_def[ :block ].call given_value, current_value
          
          if new_value != current_value
            delta[ name_sym ] = new_value
          end
        end
        
      end # try_critical_code
    end # hash.each_with_object
  end # #delta
  
  
  # Merge the data in an object over that in this instance to create a new one.
  #
  # Accepts other {Options} instances, {::Hash}es of option names to values, and
  # `nil` (which always returns `self`).
  #
  # Given the immutability of {Options}, attempts to return `self` if it
  # determines no changes will be made.
  # 
  # @overload merge nil
  #   When `nil` is given, this {Options} is returned.
  #   
  #   This allows methods to take an options argument that defaults to `nil` and
  #   merge that with a default {Options} to get the working map without any
  #   additional {Options} instances being created.
  #   
  #   @param [nil] nil
  #   @return [self]
  # 
  # @overload merge options
  #   Merge the values from another {Options} over those in this one to create
  #   a new {Options}.
  #   
  #   As an optimization, if the values in the `options` argument are the same
  #   (`==` comparison) as those in this one simply returns `self`.
  #   
  #   @param [Options] options
  #   @return [Options]
  #
  # @overload merge hash
  #   Merge values from a name/value {::Hash} over those in this {Options} to
  #   create a new instance.
  #   
  #   If the values in the `hash` are all the same as those in this instance
  #   (`==` comparison) simply returns `self`.
  #   
  #   @param [::Hash<(::Symbol | ::String), ::Object>] hash
  #     Map of option names to values.
  # 
  # @raise [::TypeError]
  #   When the argument is not of a suitable type *and* 
  #   {Support::CriticalCode.enabled?} is false.
  # 
  # @see #update
  # @see #apply
  # 
  def merge object
    case object
    when nil, self
      self
    when Options
      merge object.to_hash
    when ::Hash
      delta = self.delta object
      
      return self if delta.empty?
      
      derive do |new_options|
        delta.each do |name, value|
          new_options.instance_variable_set "@#{ name }", value
        end
      end
    else
      try_critical_code default: self do
        raise ::TypeError,
          "Expected `nil`, `self` or {::Hash}, given {#{ object.class }}:" +
          object.inspect
      end
    end
  end # #merge
  
  
  # Merge a single option.
  # 
  # @overload merge name, value
  #   Basically just calls {#merge} with `name => value`.
  #   
  #   @param [::Symbol | ::String] name
  #   @return [Options]
  # 
  # @overload merge name, &block
  #   Calls `&block` with the option's current value and uses the response as
  #   the value in {#merge}.
  #   
  #   @param [::Symbol | ::String] name
  #   @return [Options]
  # 
  def update name, *args, &block
    try_critical_code default: self do
      value = if block
        block.call get!( name )
      else
        unless args.length == 1
          raise ::ArgumentError,
            "Expected 2 arguments (name, value) when no block given, " +
            "received #{ args.length + 1 }: #{ [ name, *args ].inspect }"
        end
        
        args[ 0 ]
      end # value = 
      
      merge name => value
    end # try_critical_code
  end # #update
  
  
  # Return a new instance with a single option changed, the value of which is
  # computed by calling a method on the current value.
  # 
  # @example
  #   options = ::NRSER::Text::Renderer::Options.new  word_wrap: 80,
  #                                                   code_indent: 4
  #   
  #   updated = options.apply :word_wrap, :-, options.code_indent
  #   
  #   updated.word_wrap == 76
  #   #=> true
  # 
  # @return [Options]
  #   If the operation succeeded, the new {Options} instance with updated 
  #   `option_name` value.
  #   
  #   If the operation failed *and* {Support::CriticalCode.enabled?} is true,
  #   a warning will be written to the standard error stream and *this* instance
  #   will be returned.
  #   
  # @raise [::KeyError]
  #   If `option_name` is not an option *and* {Support::CriticalCode.enabled?} 
  #   is false.
  # 
  # @raise
  #   If {Support::CriticalCode.enabled?} is false, any errors that the method
  #   call in the current value raise will be propagated.
  # 
  def apply option_name, method_name, *args, &block
    try_critical_code default: self do
      value = get!( option_name ).public_send method_name, *args, &block
      merge option_name => value
    end
  end # #apply
  
  # @!endgroup Merging Instance Methods # ************************************
  
  
  # @!group Language Integration Instance Methods
  # --------------------------------------------------------------------------
  
  def == other
    other.is_a?( Options ) && to_h == other.to_h
  end
  
  
  # Allow implicit casts to {::Hash}.
  # 
  # @return [::Hash<::Symbol, ::Object>]
  # 
  def to_hash
    self.class.each_option_def.each_with_object( {} ) { |option_def, hash|
      hash[ option_def[ :name ] ] = self[ option_def[ :name ] ]
    }
  end # #to_hash
  
  
  # Get a {::Hash} representation of the options.
  # 
  # @return [::Hash<::Symbol, ::Object>]
  #  
  def to_h; to_hash; end
  
  
  def dup
    raise ::NotImplementedError,
      "{#{ self.class }} are immutable, can't duplicate (and don't need to)"
  end
  
  
  def clone
    raise ::NotImplementedError,
      "{#{ self.class }} are immutable, can't clone (and don't need to)"
  end
  
  # @!endgroup Language Integration Instance Methods # ***********************
  
end # class Options


# /Namespace
# =======================================================================

end # class   Renderer
end # module  Text
end # module  NRSER
