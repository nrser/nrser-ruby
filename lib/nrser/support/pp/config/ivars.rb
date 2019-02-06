# encoding: UTF-8
# frozen_string_literal: true
# doctest: true

# Requirements
# =======================================================================

### Stdlib ###

require 'set'

### Deps ###

# Using {::Object#present?}
require 'active_support/core_ext/object/blank'

### Project / Package ###

# Logging
require "nrser/log"

# Using {NRSER::Meta::Names::Var::Instance} to validate ivar names
require 'nrser/meta/names/var'


# Namespace
# =======================================================================

module  NRSER
module  Support
module  PP
class   Config


# Definitions
# =======================================================================

# A probably totally over-engineered configurator class to handle which instance
# variables {NRSER::Support::PP} prints. But, hey, I wrote it, so, whatever,
# it's here.
#
# @note Don't instantiate classes directly, use the {.make} factory method!
#
#   Lots of examples there on how the configuration works.
#
# Instances are created with {.make} from  a configuration, and mainly provide
# {#values_for}, which takes an object and returns a sorted array of `[name,
# value]` pair arrays to print.
#
# Generally works along the `only` / `except` lines that you see in Rails, like
# in filters and shit, implemented through the {IVars::Only} and {IVars::Except}
# subclasses.
# 
# Instances of {IVars} itself output values for names returned by instance's
# `#pretty_print_instance_variables` methods, subject to the {#mode}.
#
class IVars
  
  # Constants
  # ==========================================================================
  
  # The valid modes.
  # 
  # @return [Set<Symbol>]
  # 
  MODES = Set[ :always, :never, :defined, :present ]
  
  
  # The default {#mode} if none is provided.
  # 
  # @return [Symbol]
  # 
  DEFAULT_MODE = :defined
  
  
  # Mixins
  # ==========================================================================
  
  # Add {.logger} and {#logger} methods
  include NRSER::Log::Mixin
  
  
  # Singleton Methods
  # ==========================================================================
  
  # Normalize `object` to a Symbol instance variable name using 
  # {NRSER::Meta::Names::Var::Instance}, or raise if it can't be done.
  # 
  # @return [Symbol]
  #   Instance variable name (like `:@x`).
  # 
  def self.name_for! object
    NRSER::Meta::Names::Var::Instance.new( object ).to_sym
  end
  
  
  # Get a value from {MODES} for `object`, and raise if that's not possible.
  # Used to convert and validate modes.
  # 
  # 1.  Values in {MODES} are returned.
  #     
  # 2.  `true` is converted to `:always`.
  #     
  # 3.  `false` is converted to `:never`.
  #     
  # 4.  Anything else has `.to_s.to_sym` called on it, and if *that's* not in
  #     {MODES} raises {NRSER::ArgumentError}.
  # 
  # @return [Symbol]
  #   One of {MODES}.
  # 
  # @raise [NRSER::ArgumentError]
  #   If a valid mode can't be matched to `object`.
  # 
  def self.mode_for! object
    case object
    when ::Symbol
      if MODES.include? object
        object
      else
        raise NRSER::ArgumentError.new \
          "Mode must be `true` (=`:always`), `false` (=`:never`) or one of",
          MODES, "found", object
      end
    when true
      :always
    when false
      :never
    else
      mode_for! object.to_s.to_sym
    end
  end
  
  
  # Attributes
  # ==========================================================================
  
  # One of {MODES} to process variables in that do not have a specific mode
  # configured for them.
  # 
  # Defaults to {DEFAULT_MODE}.
  # 
  # @return [Symbol]
  #     
  attr_reader :mode
  
  
  # Instantiate one of {IVars}, {IVars::Only} or {IVars::Except} depending on
  # the parameters.
  #   
  # @example 1.  Get values for everything in `#pretty_print_instance_variables`
  #   # (in the {DEFAULT_MODE}, which is `:defined`)
  #   
  #   ivars = ::NRSER::Support::PP::Config::IVars.make
  #   
  #   class A
  #     def initialize
  #       @x = 1; @y = 2; @z = 3
  #     end
  #   end
  #   
  #   ivars.values_for A.new
  #   #=> [ [:@x, 1], [:@y, 2], [:@z, 3] ]
  # 
  # 
  # @example 2.  Get values *only* for `@x` and `@y`
  #   # in the {DEFAULT_MODE} of `:defined`, so only those that are defined as 
  #   # well.
  #   # 
  #   # NOTE  This configuration doesn't call `#pretty_print_instance_variables` 
  #   #       at all.
  # 
  #   ivars = ::NRSER::Support::PP::Config::IVars.make \
  #     only: [ :@x, :@y ]
  #   
  #   class A
  #     def initialize
  #       @x = 1; @y = 2; @z = 3
  #     end
  #   end
  #   
  #   ivars.values_for A.new
  #   #=> [ [:@x, 1], [:@y, 2] ]
  #   
  #   class B
  #     def initialize
  #       @x = 1; @z = 3
  #     end
  #   end
  #   
  #   # Because `@y` is not defined, it will be omitted.
  #   ivars.values_for B.new
  #   #=> [ [:@x, 1] ]
  #   
  # 
  # @example 3.  Variation of (2) with `mode` set to `:always`
  #   # Which causes `nil` to be output for undefined variables.
  #   
  #   ivars = ::NRSER::Support::PP::Config::IVars.make \
  #     mode: :always,
  #     only: [ :@x, :@y ]
  #   
  #   class C
  #     def initialize
  #       @x = 1; @z = 3
  #     end
  #   end
  #   
  #   # Now we see the `nil` value for undefined `@y`:
  #   ivars.values_for C.new
  #   #=> [ [:@x, 1], [:@y, nil] ]
  # 
  # 
  # @example 4.  Get values *except* `@x` and `@y`
  #   # in the {DEFAULT_MODE} of `:defined`, so only those that are defined as 
  #   # well.
  # 
  #   ivars = ::NRSER::Support::PP::Config::IVars.make \
  #     except: [ :@x, :@y ]
  #   
  #   class A
  #     def initialize
  #       @x = 1; @y = 2; @z = 3
  #     end
  #   end
  #   
  #   ivars.values_for A.new
  #   #=> [ [:@z, 3] ]
  # 
  # 
  # @example 5.  Set modes for individual variables in `only:`
  #   # Only get value for `@x`, `@y`, and `@z`, and:
  #   # 
  #   # 1.  Always include `@x`, regardless of its value or if it's even defined.
  #   #     
  #   # 2.  Include `@y` if it's defined.
  #   #     
  #   # 3.  Include `@z` if its value is "present" (via ActiveSupport's 
  #   #     {Object#present?} extension).
  #   # 
  #   ivars = ::NRSER::Support::PP::Config::IVars.make \
  #     only: { :@x => :always, :@y => :defined, :@z => :present }
  #   
  #   # This does the same thing
  #   ivars_alt = ::NRSER::Support::PP::Config::IVars.make \
  #     only: { always: :@x, defined: [ :@y ], present: :@z }
  #   
  #   class A
  #     def initialize
  #       @x = 1; @y = 2; @z = 3
  #     end
  #   end
  #   
  #   ivars.values_for A.new
  #   #=> [ [:@x, 1], [:@y, 2], [:@z, 3] ]
  #   
  #   ivars_alt.values_for A.new
  #   #=> [ [:@x, 1], [:@y, 2], [:@z, 3] ]
  #   
  #   class B
  #     def initialize
  #       # Notice `@x` is missing, and `@z` is empty (which is not present).
  #       @y = 2; @z = ""
  #     end
  #   end
  #   
  #   ivars.values_for B.new
  #   #=> [ [:@x, nil], [:@y, 2] ]
  # 
  #   ivars_alt.values_for B.new
  #   #=> [ [:@x, nil], [:@y, 2] ]
  # 
  #
  # @example 6.  Set modes for individual variables in `except:`
  #   # Get all of `#pretty_print_instance_variables` that are *defined*,
  #   # except *always* print `:@x` and `:@y`, and *never* print `@z`
  #   
  #   ivars = ::NRSER::Support::PP::Config::IVars.make \
  #     mode: :defined,
  #     except: { :@x => :always, :@y => :always, :@z => :never }
  # 
  #   # This does the same thing
  #   ivars_alt = ::NRSER::Support::PP::Config::IVars.make \
  #     mode: :defined,
  #     except: { always: [ :@x, :@y ], never: :@z }
  #   
  #   class A
  #     def initialize
  #       @w = 0; @x = 1; @y = 2; @z = 3
  #     end
  #   end
  #   
  #   ivars.values_for A.new
  #   #=> [ [:@w, 0], [:@x, 1], [:@y, 2] ]
  # 
  #   ivars_alt.values_for A.new
  #   #=> [ [:@w, 0], [:@x, 1], [:@y, 2] ]
  #   
  #   class B
  #     def initialize
  #       # Notice `@x` is missing
  #       @w = 0; @y = 2; @z = 3
  #     end
  #   end
  #   
  #   ivars.values_for B.new
  #   #=> [ [:@w, 0], [:@x, nil], [:@y, 2] ]
  # 
  #   ivars_alt.values_for B.new
  #   #=> [ [:@w, 0], [:@x, nil], [:@y, 2] ]
  # 
  # @param [Symbol] mode
  #   One of {MODES} to be the default mode for variables that don't specify 
  #   one in `only` or `except`.
  # 
  # @param [nil | Array | Hash] only
  #   Optional configuration specifying exactly which variables to get from
  #   instances. May also include specific modes for each. See examples.
  #   
  #   Incompatible with (non-`nil`) `expect`.
  # 
  # @param [nil | Array | Hash] except
  #   Optional configuration to omit or change behavior of specific variables,
  #   see examples.
  # 
  #   Incompatible with (non-`nil`) `only`.
  # 
  # @return [IVars]
  #   If `only` and `except` are both `nil`.
  # 
  # @return [IVars::Only]
  #   If `only` is not `nil`.
  # 
  # @return [IVars::Except]
  #   If `except` is not `nil`.
  # 
  # @raise [NRSER::ArgumentError]
  #   If `only` and `except` are both not `nil`.
  # 
  def self.make mode: DEFAULT_MODE, only: nil, except: nil
    if only && except
      raise NRSER::ArgumentError.new \
        "Don't provide both `only:` and `except:``",
        only: only,
        except: except
    end
    
    if only
      IVars::Only.new mode: mode, only: only
    elsif except
      IVars::Except.new mode: mode, except: except
    else
      IVars.new mode: mode
    end
  end
  
  
  # Construction
  # ==========================================================================
  
  # Instantiate a new `IVars`.
  def initialize mode: DEFAULT_MODE
    @mode = self.class.mode_for! mode
  end # #initialize
  
  
  # Instance Methods
  # ==========================================================================
  
  # Is this a {IVars::Only} instance?
  # 
  # @return [Boolean]
  # 
  def only?
    self.class == IVars::Only
  end
  
  
  # Is this an {IVars::Except} instance?
  # 
  # @return [Boolean]
  # 
  def except?
    self.class == IVars::Except
  end
  
  
  # Extract the relevant instance variable names and values from `instance`
  # according to the configuration.
  # 
  # @param [Object] instance
  #   The object to get the values from.
  #   
  #   Calls `object.pretty_print_instance_variables` to get a list of variable 
  #   names if needed, which is assumed to return a sorted list of names.
  # 
  # @param [Array] add_to
  #   Option array to add the name/value pairs to instead of creating a new one.
  #
  # @return [::Array<::Array<(Symbol, Object)>>]
  #   Array of instance variable name and value pairs.
  #
  def values_for instance, add_to: []
    add_to.tap do |values|
      instance.pretty_print_instance_variables.each { |name|
        process_value values, instance, name, self.mode
      }
    end # add_to.tap
  end # #values_for
  
  
  protected
  # ========================================================================
    
    # Get the value for a instance variable `name` from an `instance`, or 
    # return an `ErrorString` noting the failure.
    # 
    # @note
    #   Called during **print-time**, so it should *never* raise!
    # 
    # @param [Object] instance
    #   The object to get the variable value from.
    # 
    # @param [Symbol] name
    #   The name of the instance variable to get, in full `:@x` format.
    # 
    # @return [Object] 
    # 
    def value_for instance, name
      instance.instance_variable_get name
    rescue Exception => error
      ErrorString.new( "getting ivar #{ name }", error )
    end
    
    
    # Add the `[ name, value ]` pair for `name` from `instance` to values *if*
    # it should be added, considering the `mode` (mutates `values`).
    # 
    # @note
    #   Called during **print-time**, so it should *never* raise!
    #
    # Used internally, and scoped as *protected* pretty much just to keep the
    # public API simple; don't mutate the instance state or do anything funky.
    # 
    # @param [Array<Array<(Symbol, Object)>>] values
    #   Array of `[ name, value ]` pair arrays to add to.
    # 
    # @param [Object] instance
    #   The object we're getting instance variables from.
    # 
    # @param [Symbol] name
    #   The instance variable name, in full `:@x` format.
    # 
    # @param [Symbol] mode
    #   One of {MODES} dictating when the name/value pair should be added.
    # 
    # @return [nil]
    #   Mutates `values`.
    # 
    def process_value values, instance, name, mode
      case mode
      when :never
        # pass
      when :always
        values << [ name, value_for( instance, name ) ]
      when :defined
        if instance.instance_variable_defined? name
          values << [ name, value_for( instance, name ) ]
        end
      when :present
        value = value_for instance, name
        if value.present?
          values << [ name, value ]
        end
      else
        raise NRSER::UnreachableError.new \
          "Bad `mode` parameter", mode, ", expected one of", MODES,
          "This should not happen!"
      end
      
      nil
    rescue Exception => error
      logger.error error
    end # #process_value
  
  public # end protected ***************************************************
  
end # class IVars


class IVars::Only < IVars
  
  # Get the internal configuration data structure.
  # 
  # This is mostly for debugging... it returns the actual internal object,
  # which is mutable. If you mutate it, all hell will likely break lose.
  # Just a heads up.
  # 
  # @return [Array | Hash]
  # 
  attr_reader :only
  
  
  # Construction
  # ==========================================================================
  
  # Instantiate a new {IVars::Only} config that only outputs values for instance
  # variables that are explicitly configured, ignoring instance's 
  # `#pretty_print_instance_variables` methods (never calls them!).
  # 
  def initialize mode: DEFAULT_MODE, only:
    super( mode: mode )
  
    @only = case only
    when ::Array
      only.map { |obj| self.class.name_for! obj }.sort
    
    when ::Hash
      only.each_with_object( {} ) { |(key, value), normalized|
        # Is this a `{ MODE: [ NAME ] }` pair? I.E., is the key a mode?
        if MODES.include? key
          unless key == :never
            [ *value ].each { |name_obj|
              normalized[ self.class.name_for! name_obj ] = key
            }
          end
        else
          mode = self.class.mode_for! value
          
          if mode != :never
            normalized[ self.class.name_for! key ] = mode
          end
        end
      }.to_a.sort

    else
      raise NRSER::ArgumentError.new \
        "`only:` must be", ::Array, "of ivar name selectors, or",
        ::Hash, "of either `(NAME, MODE)` or `(MODE, [NAME])`",
        "found:", only
    end
  end # #initialize
  
  
  # Instance Methods
  # ==========================================================================
  
  # {include:IVars#values_for}
  def values_for instance, add_to: []
    add_to.tap do |values|
      only.each { |(name, mode)|
        process_value values, instance, name, mode || self.mode
      }
    end # add_to.tap
  end # #values_for
  
end # class IVars::Only


# An {IVars} that processes everything from `#pretty_print_instance_variables`
# as usual *except* as layed out in it's {#except} configuration, which may
# include different names and modes for specific vars.
# 
# Take a look at {IVars.make} for examples, and use that method to create these.
# 
class IVars::Except < IVars
  
  # Get the internal configuration data structure.
  # 
  # This is mostly for debugging... it returns the actual internal object,
  # which is mutable. If you mutate it, all hell will likely break lose.
  # Just a heads up.
  # 
  # @return [Array | Hash]
  # 
  attr_reader :except
  
  
  # Construction
  # ==========================================================================
  
  # Instantiate a new `IVars::Except`.
  # 
  def initialize mode: DEFAULT_MODE, except:
    super( mode: mode )
    
    @except = case except
    when ::Array
      except.map { |obj| self.class.name_for! obj }
    
    when ::Hash
      except.each_with_object( {} ) { |(key, value), normalized|
        # Is this a `{ MODE: [ NAME ] }` pair? I.E., is the key a mode?
        if MODES.include? key
          [ *value ].each { |name_obj|
            normalized[ self.class.name_for! name_obj ] = key
          }
        else
          normalized[ self.class.name_for! key ] = \
            self.class.mode_for! value
        end
      }

    else
      raise NRSER::ArgumentError.new \
        "`except:` must be", ::Array, "of ivar name selectors, or",
        ::Hash, "of either `(NAME, MODE)` or `(MODE, [NAME])`",
        "found:", except
    end
    
  end # #initialize
  
  
  # Instance Methods
  # ==========================================================================
  
  # {include:IVars#values_for}
  def values_for instance, add_to: []
    add_to.tap do |values|
      names_for( instance ).each { |name|
        mode = if ::Hash === except
          except[ name ] || self.mode
        else
          if except.include? name
            :never
          else
            self.mode
          end
        end
      
        process_value values, instance, name, mode
      }
    end
  end # #values_for
  
  
  protected
  # ========================================================================
    
    # Helper to put together the variable names that we want to read, since it's
    # a bit more complicated with {IVars::Except} instances... 
    #
    # Any variables in the config that are not `:never` mode may need to appear
    # in the {#values_for} response even though they are not in
    # `instance.pretty_print_instance_variables`.
    # 
    # This method takes care of merging and sorting the names if needed.
    #
    # @return [Enumerable<Symbol>]
    #   Sorted names of instance variables to get.
    #
    def names_for instance
      if ::Hash === except
        SortedSet.new( instance.pretty_print_instance_variables ) +
          except.select { |name, mode| mode != :never }.keys
      else
        instance.pretty_print_instance_variables
      end
    end
  
  public # end protected ***************************************************
  
end # class IVars::Except


# /Namespace
# =======================================================================

end # class Config
end # module PP
end # module Support
end # module NRSER

