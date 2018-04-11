# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/refinements/types'

require 'nrser/graph/tsorter'

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
    @klass.superclass.respond_to? :metadata
  end
  
  
  def superclass_metadata
     @klass.superclass.metadata
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
  
  
  # Check primary prop values and fill in defaults, yielding `(Prop, VALUE)`
  # to the `&block`.
  # 
  # Used when initializing instances.
  # 
  # @param [#each_pair | #each_index] values
  #   Collection of prop values iterable by key/value pairs or by indexed
  #   entries.
  # 
  # @param [Proc<(NRSER::Props::Prop, VALUE)>] &block
  #   Block that will receive primary prop and value pairs.
  # 
  # @raise [TypeError]
  #   If a value is does not satisfy it's {NRSER::Props::Prop#type}.
  # 
  # @raise [ArgumentError]
  #   If `values` doesn't respond to `#each_pair` or `#each_index`.
  # 
  # @raise [NameError]
  #   If a value is not provided for a primary prop and a default can not
  #   be created.
  # 
  # @raise [TSort::Cyclic]
  #   If any of the primary prop's {NRSER::Props::Prop#deps} for dependency
  #   cycles.
  # 
  def each_primary_prop_value_from values, &block
    primary_props = props only_primary: true
    
    # Normalize values to a `Hash<Symbol, VALUE>` so everything can deal with
    # one form. Default values will be set here as they're resolved and made
    # available to subsequent {Prop#default} calls.
    values_by_name = {}
    
    if values.respond_to? :each_pair
      values.each_pair { |key, value|
        # Figure out the prop name {Symbol}
        name = case key
        when Symbol
          key
        when String
          key.to_sym
        else
          key.to_s.to_sym
        end
        
        # If the `name` corresponds to a primary prop set it in the values by
        # name
        # 
        # TODO  Should check that the name is not already set?
        # 
        values_by_name[name] = value if primary_props.key? name
      }
    elsif values.respond_to? :each_index
      indexed = []
      
      primary_props.each_value do |prop|
        indexed[prop.index] = prop unless prop.index.nil?
      end
      
      values.each_index { |index|
        prop = indexed[index]
        values_by_name[prop.name] = values[index] if prop
      }
    else
      raise ArgumentError.new binding.erb <<~END
        `source` argument must respond to `#each_pair` or `#each_index`
        
        Found:
        
            <%= source.pretty_inspect %>
        
      END
    end
    
    # Topological sort the primary props by their default dependencies.
    # 
    NRSER::Graph::TSorter.new(
      primary_props.each_value
    ) { |prop, &on_dep_prop|
      # 
      # This block is responsible for receiving a {Prop} and a callback
      # block and invoking that callback block on each of the prop's
      # dependencies (if any).
      # 
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
      # {Prop} instances will now be yielded in an order that allows any
      # inter-dependencies to be resolved (as long as there weren't dependency
      # cycles, which {NRSER::Graph::TSorter} will raise if it finds)
      
      # If we have a value for the prop, just check that
      if values_by_name.key? prop.name
        prop.check! values_by_name[prop.name]
      else
        # Otherwise, get the default value, providing the values we already
        # know in case the default is a {Proc} that needs some of them.
        # 
        # We set that value in `values_by_name` so that subsequent
        # {Prop#default} calls can use it.
        # 
        values_by_name[prop.name] = prop.default **values_by_name
      end
      
      # Yield the {Prop} and it's value back to the `&block`
      block.call prop, values_by_name[prop.name]
    end # .tsort_each
  end # #each_primary_prop_value_from
  
  
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
