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
  
  STORAGE = NRSER::Props::Storage::Key.new immutable: true
  
  
  # Class Methods
  # ======================================================================
  
  def self.included base
    unless base < Hamster::Vector
      raise binding.erb <<~END
        This class is only for including in {Hamster::Vector} subclasses!
      END
    end
    
    base.include NRSER::Props
    base.metadata.storage STORAGE
    base.metadata.freeze
  end
  
  
  # Constructor
  # ======================================================================
  
  # Since including classes are using themselves as storage, we need to tap
  # into the `#initialize` chain in order to load property values from sources
  # and pass an {Array} up to the super-method to instantiate the
  # {Hamster::Vector}.
  # 
  def initialize source = {}
    values = []
    
    self.class.props( only_primary: true ).values.each do |prop|
      values[prop.key] = prop.create_value self, source
    end
    
    super values
  end # #initialize
  
end # module NRSER::Props::Immutable::Vector
