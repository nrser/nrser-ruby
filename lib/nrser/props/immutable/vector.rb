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

# Mixin for classes that extend {Hamster::Vector} and will use itself as the
# property value storage, requiring that property keys be non-negative
# integers.
# 
module NRSER::Props::Immutable::Vector
  
  # Constants
  # ==========================================================================
  
  STORAGE = NRSER::Props::Storage::Key.new immutable: true, key_type: :index
  
  
  # Module Methods
  # ======================================================================
  
  def self.included base
    unless base < Hamster::Vector
      raise "This class is only for including in {Hamster::Vector} subclasses!"
    end
    
    base.include NRSER::Props
    base.metadata.storage STORAGE
    base.metadata.freeze
    
    base.extend ClassMethods
  end
  
  
  # Mixin Methods
  # ======================================================================
  
  # Methods mixed in at the class-level.
  # 
  module ClassMethods
    # {Hamster::Vector} uses `.alloc` to quickly create derived instances
    # when it knows the instance variables. We need to hook into that to
    # check the prop types.
    # 
    # @param (see Hamster::Vector.alloc)
    # 
    # @return [Hamster::Vector]
    #   The new instance, which will be of the propertied subclass of
    #   {Hamster::Vector}.
    # 
    # @raise [TypeError]
    #   If the prop values of the new vector don't satisfy the prop types.
    # 
    def alloc *args
      super( *args ).tap do |new_instance|
        self.props( only_primary: true ).each_value do |prop|
          prop.check! new_instance[prop.index]
        end
      end
    end
  end # module ClassMethods
  
  
  # Constructor
  # ----------------------------------------------------------------------------
  
  # Since including classes are using themselves as storage, we need to tap
  # into the `#initialize` chain in order to load property values from sources
  # and pass an {Array} up to the super-method to instantiate the
  # {Hamster::Vector}.
  # 
  def initialize values = {}
    super_values = []
    
    self.class.metadata.each_primary_prop_value_from( values ) { |prop, value|
      super_values[prop.index] = value
    }
    
    super super_values
    
    # Check additional type invariants
    self.class.invariants.each do |type|
      type.check self
    end
  end # #initialize
  
end # module NRSER::Props::Immutable::Vector
