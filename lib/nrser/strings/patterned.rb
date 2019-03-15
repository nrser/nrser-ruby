# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Deps ###

# Using {::Class#descendants} in {Patterned.realizations}
require 'active_support/core_ext/class/subclasses'

### Project / Package ###

# Using {NRSER::ArgumentError}
require 'nrser/errors'

# Using {NRSER::Regexps::Composed.join} and {NRSER::Regexps::Composed.or} to
# compose {Names::Name.pattern} instances.
require 'nrser/regexps/composed'

# Using {NRSER::Ext::Class#subclass?} to safe test for subclasses
require 'nrser/ext/class/subclass'


# Namespace
# =======================================================================

module  NRSER
module  Strings


# Definitions
# =======================================================================

# Abstract base class for classes of strings that whose instances all match 
# a {.pattern} regular expression.
# 
# The {.pattern} is in fact a {NRSER::Regexps::Composed}, and the {Patterned}
# subclasses are themselves composable into new {Patterned} subclasses that 
# then provide methods for decomposing the parts of instances.
# 
class Patterned < ::String
  
  # Mixins
  # ========================================================================
  
  # Using {NRSER::Ext::Class#subclass?}
  extend NRSER::Ext::Class
  
  
  # Singleton Methods
  # ========================================================================
  
  # Declare or read the {::Regexp} pattern used to test strings for 
  # membership.
  # 
  # @overload pattern
  #   Get the class' {::Regexp} pattern used to test strings for membership.
  # 
  #   @return [::Regexp]
  #     Regular expression that all instances must match.
  #   
  #   @raise [NRSER::RuntimeError]
  #     If this class does not have a pattern declared. This means the class 
  #     is either:
  #     
  #     1.  Abstract, and can not be instantiated.
  #     2.  Misconfigured.
  # 
  # @overload pattern *objects
  #   Declare the class' {::Regexp} pattern used to test strings for 
  #   membership.
  #   
  #   The pattern may be set only once, and should be done in the class 
  #   definition.
  #   
  #   `objects` entries that are {Name} subclasses are converted to their
  #   {.pattern}, and all entries are joined and made to match full strings
  #   using {NRSER::Ext::Regexp.join}.
  #   
  #   @see NRSER::Ext::Regexp.join
  # 
  #   @param [::Array<::Class<Name>, ::Regexp, ::String, #to_s>] objects
  #     Objects to join into the class' pattern.
  #       
  #   @return [::Regexp]
  #     The pattern.
  #   
  #   @raise [NRSER::ConflictError]
  #     If a pattern has already been declared for this class.
  # 
  def self.pattern *objects
    unless objects.empty? # (setter)
      if @pattern.is_a? ::Regexp
        raise NRSER::ConflictError.new \
          "`#{ name }.pattern` is already set to", @pattern
      end
      
      @pattern = if objects.length == 1 &&
                    objects[0].is_a?( NRSER::Regexps::Composed )
        if objects[0].full?
          objects[0]
        else
          objects[0].to_full
        end
      else
        NRSER::Regexps::Composed.join \
          *objects.map { |object|
            if subclass?( object ) then object.pattern else object end
          },
          full: true
      end
    end # if objects.empty? (setter)
    
    unless @pattern.is_a? ::Regexp
      raise NRSER::RuntimeError.new \
        self, "has no `.pattern` setup, which means it is abstract or ",
        "incorrectly configured."
    end
    
    @pattern
  end # .pattern
  
  
  def self.concrete?
    @pattern.is_a?( ::Regexp )
  end
  
  
  def self.abstract?
    !concrete?
  end
  
  
  # Get the descendant classes that are {.concrete?}. Includes `self` if the 
  # receiver is also {.concrete?}.
  # 
  # @return [Array<::Class<Patterned>>]
  # 
  # @raise [NoMethodError]
  #   If the receiver is {Patterned}. As {Pattered} is a generic utility class,
  #   it doesn't make sense to ask about everything that uses it, and doing so
  #   could incur poor performance or unintended consequences (since Ruby is
  #   so dynamic and we know nothing about loaded subclasses).
  # 
  def self.realizations
    if self.equal? Patterned
      raise NoMethodError.new \
        "May only be called on subclasses, not {Patterned} itself"
    end
    
    [ self, *descendants ].select &:concrete?
  end # .realizations
  
  
  # Get the {.concrete?} descendant classes that can be constructed from 
  # `object`. Includes `self` if the receiver class is also {.concrete?}.
  # 
  # @see .realizations
  # 
  # @return [Array<::Class<Patterned>>]
  # 
  # @raise (see .realizations)
  # 
  def self.realizations_for object
    string = object.is_a?( ::String ) ? object.to_s : object
    realizations.select { |cls| cls.pattern =~ string }
  end # .realizations_for
  
  
  # Construct an instance of a {.concrete?} subclass from `object` (if a unique
  # entry in {.realizations} can be identified, otherwise raises).
  # 
  # Per {.realizations}, `self` is also included in the candidate classes if it
  # is {.concrete?}.
  # 
  # @note
  #   Can **NOT** be called on {Patterned} itself, see notes about when 
  #   {.realizations} raises {NoMethodError}.
  # 
  # @param [#to_s] object
  #   Object the new instance will be constructed from.
  #   
  #   Its string representation (via `#to_s` if it's not already a {::String})
  #   is tested against the {.pattern}s of {.realizations} to find candidates.
  #   
  # @return [Patterned]
  #   New instance of a {.concrete?} {Patterned} subclass.
  # 
  # @raise [NRSER::CountError]
  #   If a unique subclass from {.realizations} can not be identified.
  # 
  def self.from! object
    classes = realizations_for object
    
    case classes.count
    when 0
      raise NRSER::CountError.new \
        "Object", object.inspect, "can not be used to construct", self,
        "or any of it's descendant classes",
        object: object,
        count: 0
    when 1
      classes.first.new object
    else
      raise NRSER::CountError.new \
        "Object", object.inspect, "can be used to construct multiple concrete",
        "(improper) descendant classes of", self,
        object: object,
        classes: classes,
        count: classes.count
    end
  end # .from!
  
  
  # Like {.from!}, but returns `nil` if an instance can't be constructed from 
  # `object`.
  # 
  # Per {.realizations}, `self` is also included in the candidate classes if it
  # is {.concrete?}.
  # 
  # @note
  #   Can **NOT** be called on {Patterned} itself, see notes about when 
  #   {.realizations} raises {NoMethodError}.
  # 
  # @return [Patterned]
  #   When a {.concrete?} (improper) subclass of `self` can be identified
  #   a new instance of that class is returned, constructed from `object`.
  # 
  # @return [nil]
  #   When `object` can be used to construct either zero or more than one
  #   (improper) descendant classes of the receiver.
  # 
  def self.from object
    classes = realizations_for object
    
    if classes.count == 1
      classes.first.new object
    else
      nil
    end
  end # .from
  
  
  # @!group {NRSER::Types} Integration Singleton Methods
  # --------------------------------------------------------------------------
  
  # Wrapper around {NRSER::Types.match} with special handling for {Patterned}
  # subclasses in the matcher positions.
  # 
  # When the matcher object is a *proper* subclass of {Patterned} *and* the 
  # corresponding expression responds to `#call` then the expression is wrapped
  # to create a {.new} instance of `self` to pass in.
  # 
  # @note
  #   This method will dynamically require {NRSER::Types} when called.
  #   
  #   This allows patterned strings to be used without {NRSER::Types} if 
  #   {.match} is not needed, and allowing their use in code executed before
  #   and durning loading {NRSER::Types} (as long as {.match} and any other
  #   methods that depend on {NRSER::Types} are avoided).
  #   
  # @return [Object]
  #   Totally dependent on the `clauses`.
  # 
  def self.match value, *clauses
    require 'nrser/types'
    
    NRSER::Types.match \
      value,
      *clauses.
        each_slice( 2 ).
        flat_map { |(type, expression)|
          if subclass?( type ) && expression.respond_to?( :call )
            [ type, ->( object ) { expression.call type.new( object ) } ]
          else
            [ type, expression ]
          end
        }
  end # .match
  
  
  # Create a {NRSER::Types::Type} representing the name.
  # 
  # The type tests if value's string representations (`#to_s` response)
  # matched {.pattern}.
  # 
  # @note
  #   This method will dynamically require {NRSER::Types} when called.
  #   
  #   This allows patterned strings to be used without {NRSER::Types} if 
  #   {.match} is not needed, and allowing their use in code executed before
  #   and durning loading {NRSER::Types} (as long as {.match} and any other
  #   methods that depend on {NRSER::Types} are avoided).
  # 
  # @return [NRSER::Types::Type]
  # 
  def self.to_type
    require 'nrser/types'
    
    if abstract?
      NRSER::Types.Union *realizations, name: safe_name
    else
      NRSER::Types.Union \
        NRSER::Types.When( pattern ),
        NRSER::Types.Respond( to: :to_s, with: pattern ),
        name: safe_name
    end
  end
  
  # @!endgroup {NRSER::Types} Integration Singleton Methods # ****************
  
  
  # @!group {NRSER::Regexps::Composed} Integration Singleton Methods
  # --------------------------------------------------------------------------
  # 
  # 1.  {.to_re} to convert (non-abstract) classes to a 
  #     {NRSER::Regexps::Composed} by returning {.pattern}.
  # 
  # 2.  {.+} and {.|} operator methods that allow operator composing of 
  #     (non-abstract) {Patterned} subclasses with the patterned on the 
  #     left-hand side.
  # 
  
  # Convert to a {NRSER::Regexps::Composed} by returning {.pattern}.
  # 
  # Used by {NRSER::Regexps::Composed} when composing.
  # 
  # @return [NRSER::Regexps::Composed]
  # 
  def self.to_re
    pattern
  end
  
  
  # Create a {NRSER::Regexps::Composed} that matches {.pattern} *or* `other`.
  # 
  # @see NRSER::Regexps::Composed.or
  # 
  # @param [#to_re | ::Regexp | ::String | #to_s] other
  #   The alternative pattern, which may be a regular expression or an
  #   object that's string representation will be interpreted as a regular
  #   expression source.
  #
  # @return [NRSER::Regexps::Composed]
  #   Regular expression that matches {.pattern} *or* `other`.
  # 
  def self.| other
    NRSER::Regexps::Composed.or self, other
  end
  
  
  # Create a {NRSER::Regexps::Composed} that matches {.pattern} followed by
  # `other`.
  # 
  # @see NRSER::Regexps::Composed.join
  # 
  # @param [#to_re | ::Regexp | ::String | #to_s] other
  #   The flowing pattern, which may be a regular expression or an
  #   object that's string representation will be interpreted as a regular
  #   expression source.
  #
  # @return [NRSER::Regexps::Composed]
  #   Regular expression that matches {.pattern} followed by `other`.
  # 
  def self.+ other
    NRSER::Regexps::Composed.join self, other
  end
  
  # @!endgroup {NRSER::Regexps::Composed} Integration Singleton Methods # ****
  
  
  # Construct a new {Patterned} instance.
  # 
  # `object` parameter is converted to a {::String} via `#to_s`.
  # and checked against the class' {.pattern}.
  # 
  # @param [#to_s] object
  #   String representation becomes the object.
  # 
  # @return
  #   New instance of the name class.
  # 
  # @raise [NRSER::ArgumentError]
  #   If the string representation of the `object` parameter does not match
  #   the class' {.pattern}.
  # 
  def self.new object
    string = object.to_s
    
    unless pattern =~ string
      raise NRSER::ArgumentError.new \
        self, "can only be constructed of strings that match", pattern,
        string: string,
        pattern: pattern
    end
    
    super( string ).freeze
  end # .new
  
  
  def self.=== value
    value.is_a?( self ) || pattern =~ value
  end
  
  
  # Instance Methods
  # ========================================================================
  
  
end # class Patterned

# /Namespace
# =======================================================================

end # module Strings
end # module NRSER
