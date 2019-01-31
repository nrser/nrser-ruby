# encoding: UTF-8
# frozen_string_literal: true

# TODO  I don't know if this ever worked...? Looks like it was supposed to be
#       mutable prop'd object support backed by an {NRSER::Hashes::Stash}
#       instance.

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Need {NRSER::Props} to include
require_relative '../../props'

# Need {NRSER::Stash} itself
require 'nrser/labs/stash'

# Gonna use {NRSER::Props::Storage::Key} for storage
require_relative '../storage/key'


# Declarations
# =======================================================================

module NRSER::Props::Mutable; end


# Definitions
# =======================================================================

module NRSER::Props::Mutable::Stash
  
  # Constants
  # ==========================================================================
  
  STORAGE = NRSER::Props::Storage::Key.new \
              immutable: false,
              key_type: :name,
              get: :_raw_get,
              put: :_raw_put
  
  
  # Module Methods
  # ======================================================================
  
  def self.included base
    unless base < NRSER::Hashes::Stash
      raise "This class is only for including in {Hash} subclasses!"
    end
    
    base.include NRSER::Props
    base.include InstanceMethods
    base.metadata.storage STORAGE
    base.metadata.freeze
  end
  
  # Methods to be mixed in at the class-level with
  # {NRSER::Props::Mutable::Hash}.
  module ClassMethods
    
    def [] *args
      new ::Hash[*args]
    end
    
  end # module ClassMethods
  
  
  # Instance methods to mix in with {NRSER::Props::Mutable::Hash}.
  # 
  # We want these to *override* {NRSER::Props::InstanceMethods}, so they
  # need to be separate so we can include them after {NRSER::Props} in
  # {NRSER::Props::Mutable::Hash.included}.
  # 
  module InstanceMethods

    def initialize_props values = {}
      # Handles things like `[[:x, 1], [:y, 2]]`, since we know that's what is
      # meant in that case
      values = values.to_h unless values.respond_to?( :each_pair )
      
      self.class.metadata.
        each_primary_prop_value_from( values ) { |prop, value|
          _raw_put prop.name, value
        }
      
      # Check additional type invariants
      self.class.invariants.each do |type|
        type.check self
      end
      
      # Load in additional non-prop values, if any
      # 
      # TODO  Optimize
      # 
      
      prop_names = self.class.metadata.prop_names
      
      values.each do |key, value|
        unless prop_names.include? convert_key( key )
          self[key] = value
        end
      end
    end # #initialize_props
    
    
    # Override {NRSER::Props::InstanceMethods#to_data} to handle non-prop
    # values in the {NRSER::Hashes::Stash}.
    # 
    # @param [Boolean] only_props
    #   When `true` only prop values will be added to the data hash.
    #   
    #   Otherwise, any non-prop keys and vales will be added as well
    #   (default behavior).
    # 
    # @param [Hash] kwds
    #   See {NRSER::Props::InstanceMethods#to_data}.
    # 
    # @return (see NRSER::Props::InstanceMethods#to_data)
    # 
    def to_data only_props: false, **kwds
      hash = super **kwds
      
      unless only_props
        each do |key, value|
          # Data uses **string** keys
          key = key.to_s
          
          # See if the key is missing
          unless hash.key?( key.to_s )
            # It is, so let's fill it in
            
            # If value knows how to be data, do that
            value = value.to_data if value.respond_to?( :to_data )
            
            # Set the key/value pair
            hash[key] = value
          end
        end
      end
      
      hash
    end # #to_data
    
    
    def convert_key key
      case key
      when Symbol
        key
      when String
        sym = key.to_sym
        if self.metadata[ sym ]
          sym
        else
          key
        end
      else
        key
      end
    end
    
    
    # Store a value at a key. If the key is a prop name, store it through the
    # prop, which will check it's type.
    # 
    # @param [Symbol | String] key
    # @param [VALUE] value
    # 
    # @return [VALUE]
    #   The stored value.
    # 
    def put key, value
      key = convert_key key
      
      if (prop = self.class.metadata[ key ])
        prop.set self, value
      else
        # We know {#convert_value} is a no-op so can skip it
        _raw_put key, value
      end
    end # #put
    
    
    def dup
      self.class.new( self ).tap do |new_stash|
        set_defaults new_stash
      end
    end
    
    
    # Need to patch `#merge` since {NRSER::Props::InstanceMethods} defines
    # it, which overrides {NRSER::Hashes::Stash#merge}, so we just put it back.
    # 
    def merge other_hash = {}, &block
      dup.update other_hash, &block
    end
    
  end # module InstanceMethods
  
end # module NRSER::Props::Mutable::Stash
