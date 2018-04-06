# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------
require_relative '../../props'
require_relative '../storage/key'
require_relative '../storage/instance_variables'


# Definitions
# =======================================================================

# Mix-in to store property values in instance variables of the same name.
# 
module NRSER::Props::Immutable::InstanceVariables
  
  STORAGE = NRSER::Props::Storage::InstanceVariables.new immutable: true
  
  
  # Class Methods
  # ======================================================================
  
  def self.included base
    base.include NRSER::Props
    base.metadata.storage STORAGE
    base.metadata.freeze
  end
  
  
  # Instance Methods
  # ======================================================================
  
  # Since the {NRSER::Props::Immutable::InstanceVariables} mix-in does *not*
  # need to tap into the initialize chain,
  # 
  def initialize_props values = {}
    self.class.metadata.each_primary_prop_value_from( values ) { |prop, value|
      instance_variable_set "@#{ prop.name }", value
    }
    
    # Check additional type invariants
    self.class.invariants.each do |type|
      type.check self
    end
  end # #initialize_props
  
end # module NRSER::Props::Immutable
