# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# =======================================================================

module  NRSER
module  Regexps


# Definitions
# =======================================================================

# A regular expression that may be composed of other regular expressions, and
# may be composed with other regular expressions.
# 
# To accomplish this with some minimal degree of grace and without 
# 
class Composed < ::Regexp
  
  # Constants
  # ========================================================================
  
  
  # Singleton Methods
  # ========================================================================
  
  # Construct a new {Composed} that contains the literal `strings`.
  # 
  # @param [::Array<#to_s>] strings
  #   Strings of things you want treated like strings (via `#to_s`).
  # 
  # @param [::String] join
  #   What to join multiple `strings` with.
  # 
  # @return [Composed]
  # 
  def self.quoted *strings, join: ' '
    new quote( strings.map( &:to_s ).join join )
  end
  
  
  def self.to_source object
    case object
    when ::Regexp
      object.source
    when ::String
      object
    else
      object.to_s
    end
  end
  
  
  def self.to_full_source object
    source = to_source object
    
    source = '\A' + source unless source.start_with?( '\A' )
    source = source + '\z' unless source.end_with?( '\z' )
    
    source
  end
  
  
  def self.to_fragment_source object
    source = to_source object
    
    source = source[ 2..-1 ] if source.start_with?( '\A' )
    source = source[ 0..-3 ] if source.end_with?( '\z' )
    
    source
  end
  
  
  # Compose {::Regexp} and/or {::String} sources using an *associative*
  # operation, which allows simplifying `op( op( A, B ), C ) => op( A, B, C )`,
  # resulting in cleaner composed sources.
  # 
  # @param [::Array<#to_re | ::Regexp | ::String | #to_s>] objects
  #   Elements to join (in order) to form the source for the new {::Regexp}.
  #   
  #   Objects that respond to `#to_re` have that called first to covert them to
  #   {::Regexp}. They are then passed to {.to_fragment_source}, and the
  #   resulting source strings are joined to form the new source string.
  # 
  # @param [Boolean] full
  #   When `true`, the resulting {::Regexp} will match only entire strings.
  #   
  #   This is accomplished by passing the joined source string to 
  #   {.to_full_source} before instantiating the new {::Regexp}.
  #   
  # @param [Integer | Object] options
  #   Options for the resulting new {::Regexp}.
  #   
  #   See {::Regexp.new} for details. My best understanding is that {Integer}
  #   values will be interpreted as bit-masks of {::Regexp::IGNORECASE} and 
  #   friends, while other values will be interpreted as booleans regarding
  #   case-sensitivity (`nil` and `false` meaning case-sensitive, and all other
  #   values meaning case-insensitive).
  # 
  # @return [Composed]
  #   Joined regular expression.
  # 
  # @raise [NRSER::ArgumentError]
  #   If `new:` is not {::Regexp} or a subclass of it.
  # 
  def self.compose_associative  op_name,
                                *objects,
                                full: false,
                                options: nil,
                                &block
    fragment_sources = []
    
    objects.each do |object|
      # Allow the object to become a {::Regexp} (probably a 
      # {NRSER::Regexps::Composed}) if it can do so. This was put in to support 
      # {NRSER::Meta::Names::Name} subclasses, but may be of use in other 
      # situations too.
      object = object.to_re if object.respond_to?( :to_re )
      
      if  object.is_a?( Composed ) &&
          object.composed_from &&
          object.composed_from.first == op_name
        fragment_sources.push *object.composed_from[ 1..-1 ]
      else
        fragment_sources.push to_fragment_source( object )
      end
    end
    
    source = block.call *fragment_sources
    
    source = to_full_source( source ) if full
    
    new source, options, composed_from: [ op_name, *fragment_sources ]
  end # .compose_associative
  
  
  # Join regular expressions and/or source strings into in {Composed}
  # that matches the ordered combination of them.
  # 
  # @param    (see .compose_associative)
  # @return   (see .compose_associative)
  # @raise    (see .compose_associative)
  # 
  def self.join *args
    compose_associative :join, *args do |*fragment_sources|
      fragment_sources.join ''
    end
  end # .join
  
  
  def self.to_group_source object
    "(?:#{ to_fragment_source object })"
  end
  
  
  # Join regular expressions and/or source strings into in {Composed}
  # that matches any of them.
  # 
  # @param    (see .compose_associative)
  # @return   (see .compose_associative)
  # @raise    (see .compose_associative)
  # 
  def self.or *args
    compose_associative :or, *args do |*fragment_sources|
      "(?:" +
        fragment_sources.
          map { |source| "(?:#{ source })" }.
          join( '|' ) +
      ")"
    end
  end # .or
  
  
  def self.maybe object, full: false, options: nil
    object = object.to_re if object.respond_to?( :to_re )
    
    source = "(?:#{ to_fragment_source object })?"
    
    source = to_full_source source if full
    
    new source, options
  end
  
  
  def self.any object, full: false, options: nil
    object = object.to_re if object.respond_to?( :to_re )
    
    source = "(?:#{ to_fragment_source object })*"
    
    source = to_full_source source if full
    
    new source, options
  end
  
  
  def self.esc string
    escape string
  end
  
  
  # Attributes
  # ========================================================================
  
  # Operation and source strings the instance was composed from.
  # 
  # Useful sometimes for simplifying things when composing it with other
  # regular expressions and sources.
  # 
  # @return [::Array<(::Symbol, *::String)]
  #     
  attr_reader :composed_from
  
  
  # Construction
  # ========================================================================
  
  # Instantiate a new `Composed`.
  # 
  # @overload initialize object, options, composed_from: nil
  # 
  # @overload initialize regexp
  # 
  # 
  def initialize source, *flags, composed_from: nil
    case source
    when Composed
      unless composed_from.nil?
        raise NRSER::ArgumentError.new \
          "When first param is a {::Composed} (copy constructor) can",
          "not provide `composed_from:` keyword",
          regexp: source,
          composed_from: composed_from
      end
      
      @composed_from = source.composed_from.dup.freeze
    else
      @composed_from = case composed_from
      when nil
        nil
      when ::Array
        unless composed_from[ 0 ].is_a? Symbol
          raise NRSER::ArgumentError.new \
            "First entry in `composed_from:` **must** be a {::Symbol} op name,",
            "found", composed_from[ 0 ],
            composed_from: composed_from,
            source: source
        end
        
        [
          composed_from[ 0 ],
          *composed_from[ 1..-1 ].map { |raw_component|
            self.class.to_fragment_source( raw_component ).freeze
          }
        ].freeze
      else
        raise NRSER::TypeError.new \
          "`composed_from:` must be `nil` or `Array<(Symbol, *String)>`,",
          "found", composed_from,
          composed_from: composed_from,
          source: source
      end
    end
      
    super( source, *flags )
  end # #initialize
  
  
  # Instance Methods
  # ========================================================================
  
  def full?
    source.start_with?( '\A' ) && source.end_with?( '\z' )
  end
  
  
  def fragment?
    !( source.start_with?( '\A' ) || source.end_with?( '\z' ) )
  end
  
  
  def to_full_source
    self.class.to_full_source self
  end
  
  
  def to_full
    if full?
      self
    else
      self.class.new to_full_source, options
    end
  end
  
  
  def to_fragment_source
    self.class.to_fragment_source self
  end
  
  
  def to_fragment
    if fragment?
      self
    else
      self.class.new to_fragment_source, options
    end
  end
  
  
  def join *others
    self.class.join self, *others,
      full: n_x.full?,
      options: options
  end
  
  
  def or *others
    self.class.or self, *others,
      full: n_x.full?,
      options: options
  end
  
  
  def + other
    join other
  end
  
  
  def | other
    self.or other
  end
  
end # class Composed


# /Namespace
# =======================================================================

end # module Regexps
end # module NRSER
