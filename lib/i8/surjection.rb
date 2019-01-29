# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------
require 'i8'


# HACK
class Object
  def if proc_able, &block
    block.call( self ) if proc_able.to_proc.call( self )
  end

  def unless proc_able, &block
    block.call( self ) unless proc_able.to_proc.call( self )
  end
end

# Namespace
# ========================================================================

module  I8


# Definitions
# =======================================================================

class Surjection
  
  include Hamster::Immutable

  
  # Class Methods
  # ========================================================================

  def self.[] pairs = {}
    new pairs
  end


  def self.alloc hash
    allocate.tap { |instance| instance.instance_variable_set :@hash, hash }
  end


  # Construction
  # ========================================================================

  def initialize pairs = {}
    @hash = I8::Hash[
      pairs.each_with_object( {} ) { |(keys, value), hash|
        set = I8::Set.new keys
        if hash.key? value
          hash[value] |= set
        else
          hash[value] = set
        end
      }
    ]

    @hash.values.combination( 2 ).each do |a, b|
      ( a & b ).unless( :empty? ) { |intersection|
        raise NRSER::ConflictError.new \
          "Sets", a, "and", b, "are not disjoint, sharing", intersection
      }
    end
  end


  # Instance Methods
  # ========================================================================

  def call arg
    @hash.each { |value, set| return value if set.include?( arg ) }
    nil
  end

  # The Ruby hash-ish aliases (as methods for easy subclass overrides)

  # @see #call
  def get key;  call key; end
  # @see #call
  def []  key;  call key; end


  def put arg, value
    if domain.include?( arg ) && call( arg ) != value
      raise NRSER::ConflictError.new "Already mapping", arg, "to", call( arg )
    end

    if value? value
      # We already have a set of keys mapping to the value
      if @hash[value].include? arg
        # And it already has the key, so we can just return this instance
        self
      else
        # The key set we have for the value does not have the key in it.
        # 
        # We need to 
        # 
        # 1.  Create a new hash with the key in the value's key set.
        # 2.  Allocate a new surjection.
        # 3.  set that as it's hash.
        # 
        self.class.alloc @hash.put( value ) { |set| set.add arg }
      end
    else
      # We don't have a set of keys for that value
      self.class.alloc @hash.put( value, I8::Set[ arg ] )
    end
  end

  # The standard aliases (as methods for easy subclass overrides)
  def store *args, &block; put *args, &block; end


  # The domain of the surjection (or "keys" in Ruby-Hash-y lingo).
  # 
  # @return [I8::Set]
  # 
  def domain
    @hash.each_value.reduce I8::Set.empty, :|
  end


  # The Ruby-Hash-y way of finding out if an object is in the {#domain}.
  # 
  # Functionally the same as `surjection.domain.include? obj`.
  # 
  # @param [Object] key
  # @return [Boolean]
  # 
  def key? key
    # domain.include? key
    @hash.each_value.any? { |key_set| key_set.include? key }
  end

  # The standard aliases (as methods for easy subclass overrides)

  # @see #key?
  def has_key?  key; key? key; end
  # @see #key?
  def include?  key; key? key; end
  # @see #key?
  def member?   key; key? key; end


  # The codomain of the surjection (or "values" in Ruby-Hash-y lingo).
  # 
  # @return [I8::Set]
  # 
  def codomain
    I8::Set.new @hash.keys
  end

  # The Ruby-Hash-y name (as a method for easy subclass overrides)

  # @see #codomain
  def values; codomain; end


  # Is `value` in the surjection's {#codomain}?
  # 
  # @param [Object] value
  # @return [Boolean]
  # 
  def value? value
    @hash.key? value
  end

  # The standard aliases (as methods for easy subclass overrides)

  # @see #value?
  def has_value? value; value? value; end


  def inspect
    to_s_with :inspect
  end


  def to_s
    to_s_with :to_s
  end

  
  protected
  # ========================================================================
    
    def to_s_with method_name
      "#{ self.class }[" +
      @hash.each_pair.map { |value, set|
        "{#{set.map(&method_name).join(', ')}}=>#{value.send method_name}"
      }.join( ', ' ) +
      ']'
    end
    
  public # end protected ***************************************************

end # class Surjection


# /Namespace
# ========================================================================

end # module I8
