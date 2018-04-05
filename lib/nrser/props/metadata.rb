# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Topological sort for ordering props by default dependencies
require 'tsort'

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
  
  
  class TSorter
    include TSort
    
    def initialize entries, &each_child
      @entries = entries
      @each_child = each_child
    end
    
    def tsort_each_node &block
      @entries.each &block
    end
    
    def tsort_each_child node, &block
      @each_child.call node, &block
    end
  end
  
  
  def each_prop_value_from values, &block
    primary_props = props only_primary: true
    
    # Normalize values to a `Hash<Symbol, VALUE>` so everything can deal with
    # one form
    normalized_values = {}
    
    if values.respond_to? :each_pair
      values.each_pair { |key, value|
        name = case key
        when Symbol
          key
        when String
          key.to_sym
        else
          key.to_s.to_sym
        end
        
        normalized_values[name] = value
      }
    elsif values.respond_to? :each_index
      indexed = []
      
      primary_props.each_value do |prop|
        indexed[prop.index] = prop unless prop.index.nil?
      end
      
      values.each_index { |index|
        prop = indexed[index]
        normalized_values[prop.name] = values[index] if prop
      }
    else
      raise ArgumentError.new binding.erb <<~END
        `source` argument must respond to `#each_pair` or `#each_index`
        
        Found:
        
            <%= source.pretty_inspect %>
        
      END
    end
    
    normalized_values.freeze
    
    TSorter.new( primary_props.each_value ) { |prop, &on_dep_prop|
      prop.deps.each { |name|
        if primary_props.key? name
          on_dep_prop.call primary_props[name]
        else
          raise RuntimeError.new binding.erb <<~END
            Property <%= prop.full_name %> depends on prop `<%= name %>`,
            but no primary prop with that name could be found!
          END
        end
      }
    }.tsort_each do |prop|
      block.call prop, prop.resolve_value_from( normalized_values )
    end
  end
  
  
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
