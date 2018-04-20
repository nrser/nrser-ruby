# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Deps
# -----------------------------------------------------------------------
require 'hamster'

# Project / Package
# -----------------------------------------------------------------------
require_relative '../storage/key'


# Declarations
# =======================================================================

module NRSER::Props::Immutable; end


# Definitions
# =======================================================================

# Mixin for classes that extend {Hamster::Hash} and will use itself as the
# property value storage.
# 
module NRSER::Props::Immutable::Hash
  
  # Constants
  # ==========================================================================
  
  STORAGE = NRSER::Props::Storage::Key.new immutable: true, key_type: :name
  
  
  # Module Methods
  # ======================================================================
  
  def self.included base
    unless base < Hamster::Hash
      raise binding.erb <<~END
        This class is only for including in {Hamster::Hash} subclasses!
      END
    end
    
    base.include NRSER::Props
    base.metadata.storage STORAGE
    base.metadata.freeze
    
    base.extend ClassMethods
    base.include InstanceMethods
  end
  
  
  # Mixin Methods
  # ======================================================================
  
  # Methods mixed in at the class-level.
  # 
  module ClassMethods
    # {Hamster::Hash} uses `.alloc` to quickly create derived instances
    # when it knows the instance variables. We need to hook into that to
    # check the prop types.
    # 
    # @param (see Hamster::Hash.alloc)
    # 
    # @return [Hamster::Hash]
    #   The new instance, which will be of the propertied subclass of
    #   {Hamster::Hash}.
    # 
    # @raise [TypeError]
    #   If the prop values of the new vector don't satisfy the prop types.
    # 
    def alloc *args
      super( *args ).tap do |new_instance|
        self.props( only_primary: true ).values.each do |prop|
          prop.check! new_instance[prop.name]
        end
      end
    end
  end # module ClassMethods
  
  module InstanceMethods
    # Constructor
    # ----------------------------------------------------------------------------
    
    # Since including classes are using themselves as storage, we need to tap
    # into the `#initialize` chain in order to load property values from sources
    # and pass an {Array} up to the super-method to instantiate the
    # {Hamster::Hash}.
    # 
    def initialize values = {}
      # Handles things like `[[:x, 1], [:y, 2]]`
      values = values.to_h unless values.respond_to?( :each_pair )
      
      super_values = {}
      
      self.class.metadata.each_primary_prop_value_from( values ) { |prop, value|
        super_values[prop.name] = value
      }
      
      super super_values
      
      # Check additional type invariants
      self.class.invariants.each do |type|
        type.check self
      end
    end # #initialize
  end
  
end # module NRSER::Props::Immutable::Hash
