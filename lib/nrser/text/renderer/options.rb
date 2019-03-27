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
  
  USE_CLASS_DEFAULT = ::BasicObject.new
  
  
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
  
  # @!endgroup Instance Default Constants # **********************************
  
  
  # Mixins
  # ==========================================================================
  
  extend  Support::CriticalCode
  include Support::CriticalCode
  
  
  # Singleton Methods
  # ==========================================================================
  
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
  # @return [::Proc<(::Object, ::Object) → ::Object>]
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
    name = name.to_sym if name.is_a?( ::String )
    
    if option_defs.key? name
      option_defs[ name ]
    elsif superclass && superclass <= Options
      superclass.get_option_def name
    else
      nil
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
  
  
  def_option :list_indent, default: DEFAULT_LIST_INDENT,
    &non_negative_integer_option_block_for( :list_indent )
  
  
  def_option :list_header_depth, default: DEFAULT_LIST_HEADER_DEPTH,
    &non_negative_integer_option_block_for( :list_header_depth )
  
  
  def_option :code_indent, default: DEFAULT_CODE_INDENT,
    &non_negative_integer_option_block_for( :list_header_depth )
  
  
  # Construction
  # ==========================================================================
  
  # Instantiate a new `Options`.
  # 
  def initialize **options
    options.each do |name, value|
      set_option! name, value
    end
  end # #initialize
  
  
  # Instance Methods
  # ==========================================================================
  
  protected
  # ========================================================================
    
    def set_option! name, value, default: USE_CLASS_DEFAULT
      option_def = self.class.get_option_def name
      
      if option_def.nil?
        try_critical_code do
          raise ::ArgumentError, "Option #{ name } does not exist"
        end
        
        return # If we warned
      end
      
      default = self[ option_def[ :name ] ]
      
      ivar_name = "@#{ option_def[ :name ] }"
      
      ivar_value = try_critical_code default: default do
        option_def[ :block ].call value, default
      end
      
      instance_variable_set ivar_name, ivar_value
      
      nil
    end # #set_option!
    
  public # end protected ***************************************************
  
  
  def merge object
    case object
    when nil, self
      self
    when Options
      merge object.to_hash
    when ::Hash      
      dup.tap do |new_options|
        object.each do |name, value|
          new_options.set_option! name, value
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
  
  
  def update name, &block
    try_critical_code default: self do
      dup.tap { |options|
        options.set_option! name, block.call( self[ name ] )
      }
    end
  end
  
  
  def dup
    super
  end
  
  
  # Get an option value by name.
  # 
  # @param [::Symbol | ::String] name
  #   Name of the option.
  # 
  # @return [nil]
  #   There is no `name` option.
  # 
  # @return [::Object]
  #   The option value (or default).
  # 
  def [] name
    ivar_name = "@#{ name }"
    
    if instance_variable_defined? ivar_name
      instance_variable_get ivar_name
    else
      option_def = self.class.get_option_def name
      
      if option_def.nil?
        nil
      else
        option_def[ :default ]
      end
    end
  end # #[]
  
  
  # Language Integration Instance Methods
  # --------------------------------------------------------------------------
  
  def to_hash
    self.class.each_option_def.each_with_object( {} ) { |option_def, hash|
      hash[ option_def[ :name ] ] = self[ option_def[ :name ] ]
    }
  end # #to_hash
  
end # class Options


# /Namespace
# =======================================================================

end # class   Renderer
end # module  Text
end # module  NRSER
