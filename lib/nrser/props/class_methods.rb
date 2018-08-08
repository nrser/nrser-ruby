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
require_relative './metadata'

# Refinements
# =======================================================================


# Declarations
# =======================================================================

module NRSER::Props; end


# Definitions
# =======================================================================


# Class method "macros" that are extended in to data classes, providing the
# declaration interface.
# 
module NRSER::Props::ClassMethods
  
  include NRSER::Log::Mixin
  
  # Get the metadata object for this class, creating it if it doesn't exist.
  # 
  # @return [NRSER::Props::Metadata]
  # 
  def metadata
    # TODO  Move into {NRSER::Props::Metadata}?
    #       
    unless NRSER::Props::Metadata.has_metadata? self
      instance_variable_set \
        NRSER::Props::Metadata::VARIABLE_NAME,
        NRSER::Props::Metadata.new( self )
    end
    
    NRSER::Props::Metadata.metadata_for self
  end
  
  
  def props *args, &block
    metadata.props *args, &block
  end
  
  
  def prop *args, &block
    metadata.prop *args, &block
  end
  
  
  def prop_for name_or_alias, *props_args
    sym = name_or_alias.to_sym
    
    props( *props_args ).each_value.find { |prop|
      prop.name == sym || prop.aliases.include?( sym )
    }
  end
  
  
  def invariants *args, &block
    metadata.invariants *args, &block
  end
  
  
  def invariant *args, &block
    metadata.invariant *args, &block
  end
  
  
  # Instantiate from a data hash.
  # 
  # @todo
  #   This needs to be extended to handle prop'd classes nested in
  #   arrays and hashes... but for the moment, it is what it is.
  #   
  #   This *may* have been fixed...?
  # 
  # @param [#each_pair] data
  # 
  # @return [self]
  # 
  # @raise [NRSER::ArgumentError]
  #   If `data` does not respond to `#each_pair`.
  # 
  def from_data data
    values = {}
    
    unless data.respond_to? :each_pair
      raise NRSER::ArgumentError.new \
        "`data` argument must respond to `#each_pair`",
        data: data,
        class: self
    end
    
    data.each_pair do |data_key, data_value|
      prop_key = case data_key
      when Symbol
        data_key
      when String
        data_key.to_sym
      end
      
      if  prop_key &&
          (prop = prop_for( prop_key, only_primary: true ))
        values[prop_key] = prop.value_from_data data_value
      end
    end
    
    self.new values
  end # #from_data
  
  
  # Get an instance from a source.
  # 
  # @status
  #   Experimental
  # 
  # @param [self | String | Hash] source
  # @return [self]
  # 
  def self.from source
    return source if source.is_a?( self )
    return from_s( source ) if source.is_a?( String )
    return from_data( source ) if source.respond_to?( :each_pair )
    return from_data( source.to_h ) if source.respond_to?( :to_h )
    
    raise NRSER::ArgumentError.new \
      "Unable to load #{ self } from source",
      source: source
  end # .from
  
end # module NRSER::Props::ClassMethods
