# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

require 'set'

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
  #   
  #   @param [Hash] options
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
        
        NRSER::Types.maybe \
          public_send( name, *args, **factory_options ),
          **maybe_options
      end
      
      aliases.each do |alias_name|
        singleton_class.send :alias_method, "#{ alias_name }?", maybe_name
      end
      
    end
  end # #def_factory


  # Define a new type factory class method.
  # 
  # @param [#to_s] name
  #   The name of the type. Will be normalized to a string via it's `#to_s`
  #   method. 
  # 
  # @param [Boolean] maybe
  #   When `true`, adds `?`-suffixed versions of the method names that 
  #   wrap the type in a {Maybe}.
  # 
  # @param [Enumerable<#to_s>] aliases
  #   Aliases to add for the type factory method. Normalized to a {Set} of
  #   strings before use.
  # 
  # @param [nil | Symbol | Array<Symbol>] parameterize
  #   Indicates if the type is parameterized, and, if so, what arguments
  #   it's parameterized over.
  #   
  #   Right now, just prevents the `name:` being assigned as the type's name
  #   when one isn't specified, but we have high hopes for the future :)
  # 
  # @return [nil]
  # 
  def def_type  name,
                aliases: [],
                from_s: nil,
                maybe: true,
                parameterize: nil,
                symbolic: nil,
                to_data: nil,
                &body
    # Normalize to strings
    name = name.to_s
    aliases = aliases.map( &:to_s ).to_set

    # Count the required params so we know if we can take the last one as 
    # options or not.
    # 
    # For this to work, {#def_type} has to be called like
    # 
    #     def_type name,
    #     &->( arg, **option ) do
    #       # ...
    #     end
    # 
    # because the `do |arg, **option|` form marks *all* arguments as optional.
    # 
    num_req_params = body.parameters.count { |type, name| type == :req }

    define_singleton_method name, &->(*args, &block) do
      if  args.length > num_req_params &&
          args[-1].is_a?( Hash ) &&
          args[-1].keys.all? { |k| k.is_a? Symbol }
        options = args[-1]
        args = args[0..-2]
      else
        options = {}
      end

      if args.length < num_req_params
        raise ArgumentError,
          "wrong number of arguments (given #{ args.length }, " +
          "expected #{ num_req_params })"
      end

      options[:name] ||= name unless parameterize
      options[:from_s] ||= from_s
      options[:symbolic] ||= symbolic
      options[:to_data] ||= to_data
      
      body.call *args, **options, &block
    end

    underscored = name.underscore

    # Underscored names are also available!
    unless  name == underscored ||
            aliases.include?( underscored )
      aliases << underscored
    end
    
    aliases.each do |alias_name|
      if self.respond_to? alias_name
        alias_name = alias_name + '_'
      end
      
      singleton_class.send :alias_method, alias_name, name
    end
    
    if maybe && !name.end_with?( '?' )
      maybe_name = "#{ name }?"
      
      if self.respond_to? maybe_name
        maybe_name = "#{ name }_?"
      end
      
      # HACK  Ugh maybe I wrote this quick to fix it, not sure if it's a decent
      #       idea.. basically, need to figure out what `options` keys go
      #       to {.maybe} and which ones go to the regular factory... matters
      #       for shit like {.attrs} and {.hash_type} 'cause they use option
      #       keys (whether they *should* is something I've debated... sigh,
      #       it is what it is for now).
      #       
      #       So the options that go to {.maybe} just go strait through to
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
        
        NRSER::Types.maybe \
          public_send( name, *args, **factory_options ),
          **maybe_options
      end
      
      aliases.each do |alias_name|
        singleton_class.send :alias_method, "#{ alias_name }?", maybe_name
      end
      
    end

    nil
  end

  
end # module NRSER::Types::Factory
