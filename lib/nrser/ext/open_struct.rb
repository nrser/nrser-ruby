# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Stdlib
# ------------------------------------------------------------------------

# Using {::OpenStruct} of course
require 'ostruct'


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# ========================================================================

module OpenStruct

  include NRSER::Log::Mixin

  # Deeply convert a {Hash} to an {OpenStruct}.
  # 
  # @example
  #   require 'set'
  #   require 'nrser/ext/open_struct'
  #   
  #   OpenStruct.n_x.from \
  #     name: "Neilio",
  #     age:  34,
  #     likes: Set[
  #       { category: :animal, name: "Cat" },
  #       { category: :food,  name: "Taco" },
  #     ]
  #   #=> #<OpenStruct
  #   #     name="Neilio",
  #   #     age=34,
  #   #     likes=#<Set: {
  #   #       #<OpenStruct category=:animal, name="Cat">,
  #   #       #<OpenStruct category=:food, name="Taco">
  #   #     }>
  #   #   >
  # 
  # @param [#each_pair] assoc
  #   An associative (key/value) collection (like {::Hash}).
  # 
  # @return [OpenStruct]
  # 
  # @raise [NRSER::TypeError]
  #   If `assoc` does not respond to `#each_pair`.
  # 
  def self.from assoc, freeze: false
    unless assoc.respond_to? :each_pair
      raise NRSER::TypeError.new \
        "`assoc` must respond to `#each_pair`",
        assoc: assoc
    end
    
    deep_load assoc, freeze: freeze
  end # #to_open_struct
  

  # Deeply recur through collections converting associative collections to
  # {::OpenStruct} instance.
  # 
  # Used by {.from} to do the actual work.
  # 
  # @param [::OpenStruct | #each_pair | Enumerable | Object] value
  #   Value to recursively load:
  #   
  #   1.  {::OpenStruct} - simple returned (does not look inside, duplicate,
  #       or anything else).
  #       
  #       Pretty much just there to make the method idempotent so you don't 
  #       have to keep track of if it's been applied.
  #       
  #   2.  `#each_pair` - assumed to be an associative container; converted into
  #       an {::OpenStruct}. Container values will be fed back through 
  #       {.deep_load}. Keys are not modified - if they can't be converted to
  #       {::Symbol} then {::OpenStruct.new} will raise.
  #       
  #       Method does test for response to `#transform_keys`, and will use that 
  #       as a shortcut if it is available.
  #       
  #   3.  {::Enumerable} - entries are each mapped through {.deep_load}, and 
  #       the resulting array is passed to `value.class.new` to create the 
  #       result (works for {::Array} and {::Set}, and hopefully other 
  #       {::Enumerable} containers).
  #   
  #   4.  Other {::Object} - returned as is.
  # 
  # @param [Boolean] freeze
  #   When `true` all collections and values will be frozen before being
  #   returned.
  # 
  # @return [::OpenStruct]
  #   When `value` is an associative collection (supporting `#each_pair`) or
  #   already an {::OpenStruct}.
  # 
  def self.deep_load value, freeze: false
    logger.trace "Deep loading {OpenStruct}..." do {
      value: value,
      freeze: freeze,
    } end

    result = if value.is_a? ::OpenStruct
      logger.trace "Already OpenStruct" do {
        value: value
      } end
      
      # Just assume it's already taken care of if it's already an OpenStruct
      value

    elsif value.respond_to? :transform_values
      logger.trace "Responds to #transform_values" do {
        value: value
      } end
      
      # Take a more efficient shortcut for associative collections when they
      # respond to `#transform_values`.
      ::OpenStruct.new \
        value.transform_values { |v| deep_load v, freeze: freeze }

    elsif value.respond_to? :each_pair
      logger.trace "Responds to #each_pair" do {
        value: value
      } end

      ::OpenStruct.new \
        value.
          each_pair.
          map { |k, v| [ k, deep_load( v, freeze: freeze ) ] }.
          to_h

    elsif value.is_a? ::Enumerable
      # Should work for any {::Enumerable} whose constructor accepts an array.

      logger.trace "Enumerable" do {
        value: value
      } end

      value.class.new \
        value.map { |v| deep_load v, freeze: freeze }

    else
      logger.trace "No match - considered bare value" do {
        value: value,
        **[ :transform_values, :each_pair ].n_x.assoc_to { |name|
          value.respond_to? name
        },
        **[ Enumerable ].map { |cls|
          [ "is_a? #{ cls.name }".to_sym, value.is_a?( cls ) ]
        }.to_h
      } end
      
      value

    end
    
    result.freeze if freeze

    logger.trace "RETURNING" do {
      value: value,
      result: result,
      frozen?: result.frozen?,
    } end
    
    result
  end # .deep_load


  module ClassMethods

    # Recursively create {::OpenStruct} instances from associative collections.
    # 
    # See {NRSER::Ext::OpenStruct.from} for details.
    # 
    def from assoc, freeze: false
      Ext::OpenStruct.from assoc, freeze: freeze
    end # #from

  end # module ClassMethods

end # module OpenStruct


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
