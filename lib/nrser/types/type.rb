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

# Just require the errors here so we don't need to do it everywhere
require_relative './errors/check_error'
require_relative './errors/from_string_error'


# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# =======================================================================

class Type
  
  # Constructor
  # =====================================================================
  
  # Instantiate a new `NRSER::Types::Type`.
  # 
  # @param [nil | #to_s] name
  #   Name that will be used when displaying the type, or `nil` to use a
  #   default generated name.
  # 
  # @param [nil | #call] from_s
  #   Callable that will be passed a {String} and should return an object
  #   that satisfies the type if it possible to create one.
  #   
  #   The returned value *will* be checked against the type, so returning a
  #   value that doesn't satisfy will result in a {TypeError} being raised
  #   by {#from_s}.
  # 
  # @param [nil | #call | #to_proc] to_data
  #   Optional callable (or object that responds to `#to_proc` so we can
  #   get a callable) to call to turn type members into "data".
  # 
  def initialize  name: nil,
                  symbolic: nil,
                  from_s: nil,
                  to_data: nil,
                  from_data: nil
    @name = name.nil? ? nil : name.to_s
    @from_s = from_s
    @symbolic = symbolic
    
    @to_data = if to_data.nil?
      nil
    elsif to_data.respond_to?( :call )
      to_data
    elsif to_data.respond_to?( :to_proc )
      to_data.to_proc
    else
      raise TypeError.new binding.erb <<-ERB
        `to_data:` keyword arg must be `nil`, respond to `#call` or respond
        to `#to_proc`.
        
        Found value:
        
            <%= to_data.pretty_inspect %>
        
        (type <%= to_data.class %>)
        
      ERB
    end
    
    @from_data = if from_data.nil?
      nil
    elsif from_data.respond_to?( :call )
      from_data
    elsif from_data.respond_to?( :to_proc )
      from_data.to_proc
    else
      raise TypeError.new binding.erb <<-ERB
        `to_data:` keyword arg must be `nil`, respond to `#call` or respond
        to `#to_proc`.
        
        Found value:
        
            <%= from_data.pretty_inspect %>
        
        (type <%= from_data.class %>)
        
      ERB
    end
  end # #initialize
  
  
  # Instance Methods
  # ========================================================================
  
  # @!group Display Instance Methods
  # ------------------------------------------------------------------------
  # 
  # Display ends up being pretty important with types, and also ends up 
  # complete mess very easily.
  # 
  
  # Optional support for generated names to use when no name is explicitly
  # provided at initialization instead of falling back to {#explain}.
  # 
  # Realizing subclasses *SHOULD* override this method *IF* they are able to
  # generate meaningful names.
  # 
  # The {Type#default_name} implementation returns `nil` indicating it is not
  # able to generate names.
  # 
  # @return [nil]
  #   When a name can not be generated.
  # 
  # @return [String]
  #   The generated name.
  # 
  def default_name
    nil
  end


  # The name is the type as you would write it out in documentation.
  # 
  # Prefers an explicit `@name` set at initialization, falling back first
  # to {#default_name}, then to {#explain}.
  # 
  # @return [String]
  # 
  def name
    @name || default_name || explain
  end


  # Optional support for generated symbolic names to use when no symbolic name
  # is provided at initialization instead of falling back to {#name}.
  # 
  # Realizing subclasses *SHOULD* override this method *IF* they are able to
  # generate meaningful symbolic names.
  # 
  # The {Type#default_symbolic} implementation returns `nil` indicating it is 
  # not able to generate names.
  # 
  # @return [nil]
  #   When a symbolic name can not be generated.
  # 
  # @return [String]
  #   The generated symbolic name.
  # 
  def default_symbolic
    nil
  end


  # A set theory-esque symbolic representation of the type, if available.
  # 
  # Prefers an explicit `@symbolic` set at initialization, falling back to an
  # explicit `@name`, then to {#default_symbolic} and finally {#name}.
  # 
  # @return [String]
  # 
  def symbolic
    @symbolic || @name || default_symbolic || name
  end

  
  # A verbose breakdown of the implementation internals of the type.
  # 
  # Realizing classes *SHOULD* override this method with a precise 
  # implementation.
  # 
  # The {Type#explain} implementation dumps all instance variables that 
  # appear to have accessor methods and whose names to not start with `_`.
  # 
  # Check out the {file:lib/nrser/types/doc/display_table.md display table}
  # for examples.
  # 
  # @return [String]
  # 
  def explain
    @_explain ||= begin
      s = "#{ self.class.demod_name }<"

      ivars = instance_variables.
        # each_with_object( {} ) { |var_name, hash|
        each_with_object( [] ) { |var_name, array|
          method_name = var_name.to_s[1..-1]

          if  method_name.start_with?( '_' ) ||
              !respond_to?( method_name )
            next
          end

          value = instance_variable_get var_name

          unless value.nil?
            array << "#{ var_name }=#{ value.inspect }"
          end
        }.join( ', ' )
      
      s += " #{ ivars }" unless ivars.empty?
      s += '>'
      s
    end
  end # #explain


  # How to display the type. Proxies to {#symbolic}.
  # 
  # @return [String]
  # 
  def to_s
    symbolic
  end
  

  # The built-in `#inspect` method, aliased before we override it so it's
  # available here if you should want it.
  # 
  # See {#inspect} for rationale.
  # 
  # @return [String]
  # 
  alias_method :builtin_inspect, :inspect


  # Overridden to point to {#to_s}.
  # 
  # Due to their combinatoric nature, types can quickly become large data
  # hierarchies, and the built-in {#inspect} will produce a massive dump
  # that's distracting and hard to decipher.
  # 
  # {#inspect} is readily used in tools like `pry` and `rspec`, significantly
  # impacting their usefulness when working with types.
  # 
  # As a solution, we alias the built-in `#inspect` as {#builtin_inspect},
  # so it's available in situations where you really want all those gory
  # details, and point {#inspect} to {#to_s}.
  # 
  # @return [String]
  # 
  def inspect
    to_s
  end
  
  # @!endgroup Display Instance Methods # ************************************
  
  
  # @!group Validation Instance Methods
  # ------------------------------------------------------------------------
  # 
  # The core of what a type does.
  # 
  
  # See if a value satisfies the type.
  # 
  # Realizing classes **must** implement this method.
  # 
  # This implementation just defines the API; it always raises
  # {NRSER::AbstractMethodError}.
  # 
  # @param [Object] value
  #   Value to test for type satisfaction.
  # 
  # @return [Boolean]
  #   `true` if the `value` satisfies the type.
  # 
  def test? value
    raise NRSER::AbstractMethodError.new( self, __method__ )
  end
  
  # Old name for {#test?}.
  # 
  # @deprecated
  # 
  # @param  (see #test?)
  # @return (see #test?)
  # @raise  (see #test?)
  # 
  def test value; test? value; end
  
  
  # Check that a `value` satisfies the type.
  # 
  # @see #test?
  # 
  # @return [Object]
  #   The value itself.
  # 
  # @raise [NRSER::Types::CheckError]
  #   If the value does not satisfy this type.
  # 
  def check! value, &details
    # success case
    return value if test? value
    
    raise NRSER::Types::CheckError.new \
      value: value,
      type: self,
      details: details
  end
  
  # Old name for {#check!} without the bang.
  def check *args, &block; check! *args, &block; end
  
  # @!endgroup Validation Instance Methods # *******************************
  
  
  # @!group Loading Values Instance Methods
  # ------------------------------------------------------------------------
  # 
  # Types include facilities for loading values from representations and
  # encodings.
  # 
  # This was initially driven by the desire to use types to
  # declare CLI parameter schemas, as way to dispatch with the often
  # limited and arbitrary support most "CLI frameworks" have for declaring
  # option types - things like "you can have an integer, and you can
  # have an array, but you can't have an array of integers".
  # 
  # By using compossible types that can load values from strings we get a
  # system where you can easily declare whatever complex and granular types
  # you desire and have the machine automatically load and validate them,
  # as well as provide reasonable generated feedback when something doesn't
  # meet expectations, which has worked out quite well so far start to cut
  # down the amount of repetitive and error-prone "did I get what I need?
  # No, did I get exactly what I need?" bullshit in receiving data.
  # 
  # This approach is now being expanded to "data" - an ill-formed concept
  # I've been brewing of "reasonable common and portable data
  # representation" and the {NRSER::Props} system, which has been coming
  # along as well.
  # 
  
  # Test if the type knows how to load values from strings.
  # 
  # Looks for the `@from_s` instance variable or a `#custom_from_s`
  # method.
  # 
  # @note
  #   When this method returns `true` it simply indicates that some method
  #   of loading from strings exists - the load itself can of course still
  #   fail.
  # 
  # Realizing classes should only need to override this method to limited or
  # expand the scope relative to parameterized types.
  # 
  # @return [Boolean]
  # 
  def has_from_s?
    !@from_s.nil? ||
      # Need the `true` second arg to include protected methods
      respond_to?( :custom_from_s, true )
  end
  
  
  # Load a value of this type from a string representation by passing
  # `string` to the {@from_s} {Proc}.
  # 
  # Checks the value {@from_s} returns with {#check!} before returning it, so
  # you know it satisfies this type.
  # 
  # Realizing classes **should not** need to override this - they can define
  # a `#custom_from_s` instance method for it to use, allowing individual
  # types to still override that by providing a `from_s:` proc keyword
  # arg at construction. This also lets them avoid checking the returned
  # value, since we do so here.
  # 
  # @param [String] string
  #   String representation.
  # 
  # @return [Object]
  #   Value that has passed {#check!}.
  # 
  # @raise [NoMethodError]
  #   If this type doesn't know how to load values from strings.
  #   
  #   In basic types this happens when {NRSER::Types::Type#initialize} was
  #   not provided a `from_s:` {Proc} argument.
  #   
  #   {NRSER::Types::Type} subclasses may override {#from_s} entirely,
  #   divorcing it from the `from_s:` constructor argument and internal
  #   {@from_s} instance variable (which is why {@from_s} is not publicly
  #   exposed - it should not be assumed to dictate {#from_s} behavior
  #   in general).
  # 
  # @raise [TypeError]
  #   If the value loaded does not pass {#check}.
  # 
  def from_s string
    unless has_from_s?
      raise NoMethodError, "#from_s not defined for type #{ name }"
    end
    
    value = if @from_s
      @from_s.call string
    else
      custom_from_s string
    end
    
    check! value
  end
  
  
  # Test if the type can load values from "data" - basic values and
  # collections like {Array} and {Hash} forming tree-like structures.
  # 
  # Realizing classes *may* need to override this to limited or expand
  # responses relative to parameterized types.
  # 
  # @return [Boolean]
  # 
  def has_from_data?
    !@from_data.nil? ||
      # Need the `true` second arg to include protected methods
      respond_to?( :custom_from_data, true )
  end
  
  
  # Try to load a value from "data" - basic values and
  # collections like {Array} and {Hash} forming tree-like structures.
  # 
  # @param [*] data
  #   Data to try to load from.
  # 
  # @raise [NoMethodError]
  #   If {#has_from_data?} returns `false`.
  # 
  # @raise [NRSER::Types::CheckError]
  #   If the load result does not satisfy the type (see {#check!}).
  # 
  def from_data data
    unless has_from_data?
      raise NoMethodError, "#from_data not defined"
    end
    
    value = if @from_data
      @from_data.call data
    else
      custom_from_data data
    end
    
    check! value
  end
  
  # @!endgroup Loading Values Instance Methods # ***************************
  
  
  # @!group Dumping Values Instance Methods
  # ------------------------------------------------------------------------
  
  # Test if the type has custom information about how to convert it's values
  # into "data" - structures and values suitable for transportation and
  # storage (JSON, etc.).
  # 
  # If this method returns `true` then {#to_data} should succeed.
  # 
  # @return [Boolean]
  # 
  def has_to_data?
    ! @to_data.nil?
  end # #has_to_data?
  
  
  # Dumps a value of this type to "data" - structures and values suitable
  # for transport and storage, such as dumping to JSON or YAML, etc.
  # 
  # @param [Object] value
  #   Value of this type (though it is *not* checked).
  # 
  # @return [Object]
  #   The data representation of the value.
  # 
  def to_data value
    if @to_data.nil?
      raise NoMethodError, "#to_data not defined"
    end
    
    @to_data.call value
  end # #to_data
  
  # @!endgroup Dumping Values Instance Methods # ***************************
  
  
  # @!group Language Integration Instance Methods
  # ------------------------------------------------------------------------
  
  # Hook into Ruby's *case subsumption* operator to allow usage in `case`
  # statements! Forwards to {#test?}.
  # 
  # @param value (see #test?)
  # @return (see #test?)
  #   
  def === value
    test? value
  end
  
  
  # Overridden to customize behavior for the {#from_s}, {#from_data} and
  # {#to_data} methods - those methods are always defined, but we have
  # {#respond_to?} return `false` if they lack the underlying instance
  # variables needed to execute.
  # 
  # @example
  #   t1 = t.where { |value| true }
  #   t1.respond_to? :from_s
  #   # => false
  #   
  #   t2 = t.where( from_s: ->(s){ s.split ',' } ) { |value| true }
  #   t2.respond_to? :from_s
  #   # => true
  # 
  # @param [Symbol | String] name
  #   Method name to ask about.
  # 
  # @param [Boolean] include_all
  #   IDK, part of Ruby API that is passed up to `super`.
  # 
  # @return [Boolean]
  # 
  def respond_to? name, include_all = false
    case name.to_sym
    when :from_s
      has_from_s?
    when :from_data
      has_from_data?
    when :to_data
      has_to_data?
    else
      super name, include_all
    end
  end # #respond_to?
  
  
  # This small method is extremely useful - it lets you easily use types to 
  # in {Enumerable#select} and similar by returning a {Proc} that runs 
  # {#test?} on the values it receives.
  # 
  # @example Select all non-empty strings and positive integers from an enum
  #   enum.select &(non_empty_str | pos_int)
  # 
  # Pretty cool, right?
  # 
  # @return [Proc<(Object)=>Boolean>]
  # 
  def to_proc
    ->( value ) { test? value }
  end
  
  # @!endgroup Language Integration Instance Methods # *********************
  
  
  # @!group Derivation Instance Methods
  # ------------------------------------------------------------------------
  # 
  # Methods for deriving new types from `self`.
  # 
  
  # Return a *union* type satisfied by values that satisfy either `self`
  # *or* and of `others`.
  # 
  # @param [*] other
  #   Values passed through {NRSER::Types.make} to create the other types.
  # 
  # @return [NRSER::Types::Union]
  # 
  def union *others
    require_relative './combinators'
    
    NRSER::Types.union self, *others
  end # #union
  
  alias_method :|, :union
  alias_method :or, :union
  
  
  # Return an *intersection* type satisfied by values that satisfy both
  # `self` *and* all of `others`.
  # 
  # @param [Array] others
  #   Values passed through {NRSER::Types.make} to create the other types.
  # 
  # @return [NRSER::Types::Intersection]
  # 
  def intersection *others
    require_relative './combinators'
    
    NRSER::Types.intersection self, *others
  end # #intersection
  
  alias_method :&, :intersection
  alias_method :and, :intersection
  
  
  # Return an *exclusive or* type satisfied by values that satisfy either
  # `self` *or* `other` *but not both*.
  # 
  # @param [*] other
  #   Value passed through {NRSER::Types.make} to create the other type.
  # 
  # @return [NRSER::Types::Intersection]
  # 
  def xor *others
    require_relative './combinators'
    
    NRSER::Types.xor self, *others
  end # #^
  
  alias_method :^, :xor
  
  
  # Return a "negation" type satisfied by all values that do *not* satisfy
  # `self`.
  # 
  # @return [NRSER::Types::Not]
  # 
  def not
    require_relative './not'
    
    NRSER::Types.not self
  end

  alias_method :!, :not
  alias_method :~, :not
  
  # @!endgroup Derivation Instance Methods # *******************************
  
  
end # class Type


# /Namespace
# ========================================================================

end # module Types
end # module NRSER
