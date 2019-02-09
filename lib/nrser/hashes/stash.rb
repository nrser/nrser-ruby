# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Deps
# -----------------------------------------------------------------------

require "active_support/core_ext/hash/keys"
require "active_support/core_ext/hash/reverse_merge"


# Namespace
# =======================================================================

module  NRSER
module  Hashes


# Definitions
# ============================================================================

# Abstract generalization of {ActiveSupport::HashWithIndifferentAccess}.
# Extends {::Hash} and provides simple hooks for handling keys and values
# on write.
# 
class Stash < ::Hash
  
  # Construction
  # ==========================================================================
  
  def initialize(constructor = {})
    if constructor.respond_to?(:to_hash)
      super()
      update(constructor)

      hash = constructor.to_hash
      self.default = hash.default if hash.default
      self.default_proc = hash.default_proc if hash.default_proc
    else
      super(constructor)
    end
  end
  
  
  # Instance Methods
  # ==========================================================================
  
  # @!group Internal Interface
  # --------------------------------------------------------------------------
  # 
  # **WARNING!!!**  This group **MUST** come first! It uses {.alias_method} to
  #                 copy the existing implementations of {#[]=}, {#update},
  #                 and {#key?} from {::Hash}.
  #                 
  
  # Save {::Hash#[]} as {#_raw_get} for directly reading keys.
  # 
  # @!visibility protected
  # 
  alias_method :_raw_get, :[]
  protected :_raw_get
  
  
  # Save {Hash#[]=} as {#_raw_put} for directly writing keys and values.
  # 
  # @!visibility protected
  # 
  alias_method :_raw_put, :[]=
  protected :_raw_put
  
  
  # Save {Hash#update} as {#_raw_update} for directly writing many key/value
  # pairs.
  # 
  # @!visibility protected
  # 
  # @note
  #   This is a hold-over from {HashWithIndifferentAccess}; not currently in
  #   use. Note sure if it will be kept around.
  # 
  alias_method :_raw_update, :update
  protected :_raw_update
  
  
  # Save {Hash#key?} direct querying of key presence.
  # 
  # @!visibility protected
  # 
  alias_method :_raw_key?, :key?
  protected :_raw_key?
  
  
  protected
  # ========================================================================
    
    # A wrapper for {#_raw_put} that converts keys and values first.
    # 
    # @todo
    #   Note sure if I want to keep this yet...
    # 
    def _convert_and_put key, value
      _raw_put convert_key(key), convert_value(value, for: :assignment)
    end
    
  public # end protected ***************************************************
  
  
  # @!endgroup Internal Interface # ******************************************
  
  
  # @!group The Stuff You Care About
  # --------------------------------------------------------------------------
  # 
  # Most of the class is overriding {::Hash} methods to hook into these
  # methods correctly... they are what you most likely care about.
  # 
  
  # Convert an external key to the internal representation.
  # 
  # @param [*] key
  #   The externally provided key.
  # 
  # @return [*]
  #   The key to use internally.
  # 
  def convert_key key, **options
    key
  end
  

  def convert_value value, options = {}
    value
  end
  
  
  def put key, value
    _convert_and_put key, value
  end
  
  
  def []= key, value
    put key, value
  end
  
  # @!endgroup The Stuff You Care About # ************************************
  
  
  alias_method :store, :[]=
  
  
  def set_defaults(target)
    if default_proc
      target.default_proc = default_proc.dup
    else
      target.default = default
    end
  end
  
  
  # Returns +true+ so that <tt>Array#extract_options!</tt> finds members of
  # this class.
  def extractable_options?
    true
  end
  

  def self.[] *args
    new.merge! ::Hash[*args]
  end
  

  # Updates the receiver in-place, merging in the hash passed as argument:
  #
  #   hash_1 = ActiveSupport::HashWithIndifferentAccess.new
  #   hash_1[:key] = 'value'
  #
  #   hash_2 = ActiveSupport::HashWithIndifferentAccess.new
  #   hash_2[:key] = 'New Value!'
  #
  #   hash_1.update(hash_2) # => {"key"=>"New Value!"}
  #
  # The argument can be either an
  # <tt>ActiveSupport::HashWithIndifferentAccess</tt> or a regular +Hash+.
  # In either case the merge respects the semantics of indifferent access.
  #
  # If the argument is a regular hash with keys +:key+ and +"key"+ only one
  # of the values end up in the receiver, but which one is unspecified.
  #
  # When given a block, the value for duplicated keys will be determined
  # by the result of invoking the block with the duplicated key, the value
  # in the receiver, and the value in +other_hash+. The rules for duplicated
  # keys follow the semantics of indifferent access:
  #
  #   hash_1[:key] = 10
  #   hash_2['key'] = 12
  #   hash_1.update(hash_2) { |key, old, new| old + new } # => {"key"=>22}
  # 
  # @param [Proc<(KEY, CURRENT, UPDATE) => VALUE>] block
  #   Optional block to handle key conflicts.
  # 
  # @return [self]
  # 
  def update other_hash, &block
    other_hash.to_hash.each_pair do |key, value|
      key = convert_key key, for: :write
      if block && _raw_key?( key )
        value = yield key, _raw_get( key ), value
      end
      put key, value
    end
    self
  end

  alias_method :merge!, :update
  

  # Checks the hash for a key matching the argument passed in:
  #
  #   hash = ActiveSupport::HashWithIndifferentAccess.new
  #   hash['key'] = 'value'
  #   hash.key?(:key)  # => true
  #   hash.key?('key') # => true
  def key? key
    _raw_key? convert_key( key, for: :read )
  end

  def include? key; key? key; end
  def has_key? key; key? key; end
  def member? key;  key? key; end
  
  # Same as {::Hash#[]} where the key passed as argument can be
  # either a string or a symbol:
  #
  #   counters = ActiveSupport::HashWithIndifferentAccess.new
  #   counters[:foo] = 1
  #
  #   counters['foo'] # => 1
  #   counters[:foo]  # => 1
  #   counters[:zoo]  # => nil
  def [] key
    _raw_get convert_key( key, for: :read )
  end

  # Same as {::Hash#fetch} where the key passed as argument can be
  # either a string or a symbol:
  #
  #   counters = ActiveSupport::HashWithIndifferentAccess.new
  #   counters[:foo] = 1
  #
  #   counters.fetch('foo')          # => 1
  #   counters.fetch(:bar, 0)        # => 0
  #   counters.fetch(:bar) { |key| 0 } # => 0
  #   counters.fetch(:zoo)           # => KeyError: key not found: "zoo"
  def fetch key, *extras
    super convert_key( key, for: :read ), *extras
  end
  
  # Same as {::Hash#dig} where the key passed as argument can be
  # either a string or a symbol:
  #
  #   counters = ActiveSupport::HashWithIndifferentAccess.new
  #   counters[:foo] = { bar: 1 }
  #
  #   counters.dig('foo', 'bar')     # => 1
  #   counters.dig(:foo, :bar)       # => 1
  #   counters.dig(:zoo)             # => nil
  def dig *args
    args[0] = convert_key( args[0], for: :read ) if args.size > 0
    super *args
  end
  

  # Same as {::Hash#default} where the key passed as argument can be
  # either a string or a symbol:
  #
  #   hash = ActiveSupport::HashWithIndifferentAccess.new(1)
  #   hash.default                   # => 1
  #
  #   hash = ActiveSupport::HashWithIndifferentAccess.new { |hash, key| key }
  #   hash.default                   # => nil
  #   hash.default('foo')            # => 'foo'
  #   hash.default(:foo)             # => 'foo'
  def default(*args)
    super(*args.map { |arg| convert_key( arg, for: :read ) })
  end

  # Returns an array of the values at the specified indices:
  #
  #   hash = ActiveSupport::HashWithIndifferentAccess.new
  #   hash[:a] = 'x'
  #   hash[:b] = 'y'
  #   hash.values_at('a', 'b') # => ["x", "y"]
  def values_at(*indices)
    indices.collect { |key| self[ convert_key( key, for: :read ) ] }
  end

  # Returns a shallow copy of the hash.
  #
  #   hash = ActiveSupport::HashWithIndifferentAccess.new({ a: { b: 'b' } })
  #   dup  = hash.dup
  #   dup[:a][:c] = 'c'
  #
  #   hash[:a][:c] # => "c"
  #   dup[:a][:c]  # => "c"
  def dup
    self.class.new(self).tap do |new_hash|
      set_defaults(new_hash)
    end
  end

  # This method has the same semantics of +update+, except it does not
  # modify the receiver but rather returns a new hash with indifferent
  # access with the result of the merge.
  def merge(hash, &block)
    dup.update(hash, &block)
  end

  # Like +merge+ but the other way around: Merges the receiver into the
  # argument and returns a new hash with indifferent access as result:
  #
  #   hash = ActiveSupport::HashWithIndifferentAccess.new
  #   hash['a'] = nil
  #   hash.reverse_merge(a: 0, b: 1) # => {"a"=>nil, "b"=>1}
  def reverse_merge(other_hash)
    super(self.class.new(other_hash))
  end

  # Same semantics as +reverse_merge+ but modifies the receiver in-place.
  def reverse_merge!(other_hash)
    replace(reverse_merge(other_hash))
  end

  # Replaces the contents of this hash with other_hash.
  #
  #   h = { "a" => 100, "b" => 200 }
  #   h.replace({ "c" => 300, "d" => 400 }) # => {"c"=>300, "d"=>400}
  def replace(other_hash)
    super(self.class.new(other_hash))
  end

  # Removes the specified key from the hash.
  def delete key
    super( convert_key( key, for: :write ) )
  end

  # def stringify_keys!; self end
  # def deep_stringify_keys!; self end
  # def stringify_keys; dup end
  # def deep_stringify_keys; dup end
  # undef :symbolize_keys!
  # undef :deep_symbolize_keys!
  # def symbolize_keys; to_hash.symbolize_keys! end
  # def deep_symbolize_keys; to_hash.deep_symbolize_keys! end
  # def to_options!; self end

  def select(*args, &block)
    return to_enum(:select) unless block_given?
    dup.tap { |hash| hash.select!(*args, &block) }
  end

  def reject(*args, &block)
    return to_enum(:reject) unless block_given?
    dup.tap { |hash| hash.reject!(*args, &block) }
  end

  def transform_values(*args, &block)
    return to_enum(:transform_values) unless block_given?
    dup.tap { |hash| hash.transform_values!(*args, &block) }
  end

  def compact
    dup.tap(&:compact!)
  end

  # Convert to a regular hash with string keys.
  def to_hash
    _new_hash = ::Hash.new
    set_defaults(_new_hash)

    each do |key, value|
      _new_hash[key] = convert_value(value, for: :to_hash)
    end
    _new_hash
  end
  
end # class Stash


# /Namespace
# =======================================================================

end # module Hashes
end # module NRSER
