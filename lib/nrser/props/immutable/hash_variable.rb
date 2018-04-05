# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------
require_relative '../storage/key'
require_relative '../storage/instance_variable'


# Declarations
# =======================================================================

module NRSER; end
module NRSER::Props; end


# Definitions
# =======================================================================

# Mix-in to store property values in an immutable {Hamster::Hash} instance
# in an instance variable.
# 
# This is basically an improvement of how the original props implementation
# worked.
# 
module NRSER::Props::Immutable::HashVariable
  
  KEY_STORAGE = NRSER::Props::Storage::Key.new immutable: true, key_type: :name
  
  INSTANCE_VARIABLE_STORAGE = \
    NRSER::Props::Storage::InstanceVariable.new sub_storage: KEY_STORAGE
  
  
  # Class Methods
  # ======================================================================
  
  def self.included base
    base.include NRSER::Props
    base.metadata.storage INSTANCE_VARIABLE_STORAGE
    base.metadata.freeze
  end
  
  
  # Constructor
  # ======================================================================
  
  # Instantiate a new `NRSER::Props::Immutable::Vector`.
  def initialize_props values = {}
    prop_values = {}
    
    self.class.metadata.each_prop_value_from( values ) { |prop, value|
      prop_values[prop.name] = value
    }
    
    instance_variable_set self.class.metadata.storage.var_name,
                          Hamster::Hash.new( values )

    # Check additional type invariants
    self.class.invariants.each do |type|
      type.check self
    end
  end # #initialize
  
end # module NRSER::Props::Immutable::HashVariable


# @todo document NRSER::Props::Immutable::HashVariable::Base module.
class NRSER::Props::Immutable::HashVariable::Base
  
  include NRSER::Props::Immutable::HashVariable
  
  def initialize values = {}
    initialize_props values
  end
  
end # class NRSER::Props::Immutable::HashVariable::Base
