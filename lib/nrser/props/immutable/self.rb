# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------
require_relative '../storage/key'
require_relative '../storage/instance_variables'

# Refinements
# =======================================================================


# Declarations
# =======================================================================

module NRSER::Props::Immutable; end



# Definitions
# =======================================================================

# Abstract base class for data immutable data objects backed by a
# {Hamster::Vector}.
# 
module NRSER::Props::Immutable::Self
  
  # Constants
  # ============================================================================
  
  KEY_STORAGE = NRSER::Props::Storage::Key.new immutable: true
  
  INSTANCE_VARIABLES_STORAGE = \
    NRSER::Props::Storage::InstanceVariables.new immutable: true
  
  
  # Class Methods
  # ======================================================================
  
  
  # @todo Document storage_for method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.storage_for base
    if [
      Hamster::Hash,
      Hamster::Vector,
    ].any? { |klass| base <= klass }
      KEY_STORAGE
    else
      INSTANCE_VARIABLES_STORAGE
    end
  end # .storage_for
  
  
  def self.included base
    base.include NRSER::Props
    base.metadata.storage storage_for( base )
    base.metadata.freeze
  end
  
  
  # Constructor
  # ======================================================================
  
  # Instantiate a new `NRSER::Props::Immutable::Vector`.
  def initialize source = {}
    if self.class.metadata.storage.is_a? NRSER::Props::Storage::Key
      values = self.respond_to?( :each_pair ) ? {} : []
      
      self.class.props( only_primary: true ).values.each do |prop|
        values[prop.key] = prop.create_value self, source
      end
      
      super values
    
    elsif self.class.metadata.storage.is_a? \
            NRSER::Props::Storage::InstanceVariables
      self.class.props( only_primary: true ).values.each do |prop|
        instance_variable_set "@#{ prop.key }",
                              prop.create_value( self, source )
      end
      
      freeze
      
    else
      raise "BAD BAD!"
      
    end
  end # #initialize
  
  
  # Instance Methods
  # ======================================================================
  
  
end # module NRSER::Props::Immutable::Vector
