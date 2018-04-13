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


# Refinements
# =======================================================================


# Declarations
# =======================================================================


# Definitions
# =======================================================================


# @todo document NRSER::Types::Factory module.
module NRSER::Types::Factory
  
  # Define a type factory.
  # 
  # @!macro [attach] factory
  #   @param [Hash] **options
  #     Common type construction options, see {Type#initialize}.
  #   
  #   @return [NRSER::Types::Type]
  #     The type.
  # 
  def def_factory name, maybe: true, aliases: [], &body
    define_singleton_method name, &body
    
    aliases.each do |alias_name|
      if self.respond_to? alias_name
        alias_name = alias_name + '_'
      end
      
      singleton_class.send :alias_method, alias_name, name
    end
    
    if maybe && !name.to_s.end_with?( '?' )
      maybe_name = "#{ name }?".to_sym
      
      if self.respond_to? maybe_name
        maybe_name = "#{ name }_?".to_sym
      end
      
      # HACK  Ugh maybe I wrote this quick to fix it, not sure if it's a decent
      #       idea.. basically, need to figure out what `options` keys go
      #       to {.maybe} and which ones go to the regular factory... matters
      #       for shit like {.attrs} and {.hash_type} 'cause they use option
      #       keys (whether they *should* is something I've debated... sigh,
      #       it is what it is for now).
      #       
      #       So they options that go to {.maybe} just go strait through to
      #       {Type#initialize}, so just grab that method, see what keys it
      #       takes, and then can slice and dice off that...
      # 
      maybe_option_keys = Set.new \
        NRSER::Types::Type.
          instance_method( :initialize ).
          parameters.
          select { |param_type, name| param_type == :key }.
          map { |param_type, name| name }
      
      define_singleton_method maybe_name do |*args, **options|
        maybe_options = options.slice *maybe_option_keys
        factory_options = options.except *maybe_option_keys
        
        maybe public_send( name, *args, **factory_options ), **maybe_options
      end
      
      aliases.each do |alias_name|
        singleton_class.send :alias_method, "#{ alias_name }?", maybe_name
      end
      
    end
  end
  
end # module NRSER::Types::Factory
