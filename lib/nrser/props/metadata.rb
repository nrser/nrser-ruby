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
require 'nrser/refinements/types'

require_relative './prop'


# Refinements
# =======================================================================

using NRSER::Types

# Declarations
# =======================================================================

module NRSER::Props; end


# Definitions
# =======================================================================

# @todo document NRSER::Props::ClassMetadata class.
class NRSER::Props::Metadata
  
  # Constants
  # ======================================================================
  
  VARIABLE_NAME = :@__NRSER_metadata__
  
  
  # Class Methods
  # ======================================================================
  
  # @todo Document has_metadata? method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.has_metadata? klass
    klass.instance_variable_defined? VARIABLE_NAME
  end # .has_metadata?
  
  
  def self.metadata_for klass
    klass.instance_variable_get VARIABLE_NAME
  end
  
  
  # Attributes
  # ======================================================================
  
  
  # Constructor
  # ======================================================================
  
  # Instantiate a new `NRSER::Props::ClassMetadata`.
  def initialize klass
    @klass = klass
    @props = {}
    @invariants = Set.new
    @storage
  end # #initialize
  
  
  # Instance Methods
  # ======================================================================
  
  def superclass_has_metadata?
    self.class.has_metadata? @klass.superclass
  end
  
  
  def superclass_metadata
     self.class.metadata_for @klass.superclass
  end
  
  
  # Get a map of property names to property instances.
  # 
  # @param [Boolean] only_own:
  #   Don't include super-class properties.
  # 
  # @param [Boolean] only_primary:
  #   Don't include properties that have a {NRSER::Props::Prop#source}.
  # 
  # @return [Hash{ Symbol => NRSER::Props::Prop }]
  #   Hash mapping property name to property instance.
  # 
  def props only_own: false, only_primary: false
    result = if !only_own && superclass_has_metadata?
      superclass_metadata.props only_own: only_own,
                                only_primary: only_primary
    else
      {}
    end
    
    if only_primary
      @props.each {|name, prop| result[name] = prop if prop.primary? }
    else
      result.merge! @props
    end
    
    result
  end # #props
  
  
  # Define a property.
  # 
  # @param [Symbol] name
  #   The name of the property.
  # 
  # @param [Hash{ Symbol => Object }] **opts
  #   Constructor options for {NRSER::Props::Prop}.
  # 
  # @return [NRSER::Props::Prop]
  #   The newly created prop, thought you probably don't need it (it's
  #   already all bound up on the class at this point), but why not?
  # 
  def prop name, **opts
    t.sym.check name
    
    if @props.key? name
      raise ArgumentError.new binding.erb <<~END
        Prop <%= name.inspect %> already set for <%= @klass %>:
        
            <%= @props[name].inspect %>
      END
    end
    
    prop = NRSER::Props::Prop.new @klass, name, **opts
    @props[name] = prop
    
    if prop.create_reader?
      @klass.class_eval do
        define_method prop.name do
          prop.get self
        end
      end
    end
    
    if prop.create_writer?
      @klass.class_eval do
        define_method "#{ prop.name }=" do |value|
          prop.set self, value
        end
      end
    end
    
    prop
  end # #prop
  
  
  def invariants only_own: false
    result = if !only_own && superclass_has_metadata?
      superclass_metadata.invariants only_own: false
    else
      Set.new
    end
    
    result + @invariants
  end
  
  
  def invariant type
    @invariants.add type
  end
  
  
  def default_storage
    if superclass_has_metadata?
      superclass_metadata.storage
    else
      @storage = NRSER::Props::Storage::InstanceVariable.new
    end
  end
  
  
  def storage value = nil
    if value.nil?
      if @storage.nil?
        default_storage
      else
        @storage
      end
    else
      @storage = value
    end
  end
  
end # class NRSER::Props::ClassMetadata
