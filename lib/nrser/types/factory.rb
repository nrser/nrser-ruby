# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

require 'set'

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/errors/type_error'

# Namespace
# =======================================================================

module  NRSER
module  Types


# Definitions
# =======================================================================

# Mixin that provides {#def_type} to create type factory class methods.
# 
# Mixed in to {NRSER::Types}, but can also be mixed in by libraries using
# the types system to define their own types.
# 
module Factory
  
  # Define a type factory.
  # 
  # @deprecated Use {#def_type}
  # 
  def def_factory name, maybe: true, aliases: [], &body
    define_singleton_method name, &body

    aliases.each do |alias_name|
      if self.respond_to? alias_name
        alias_name = alias_name.to_s + '_'
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
        maybe_alias_name = "#{ alias_name }?"

        if self.respond_to? maybe_alias_name
          maybe_alias_name = "#{ alias_name }_?"
        end

        singleton_class.send :alias_method, maybe_alias_name, maybe_name
      end
      
    end
  end # #def_factory


  # Define a new type factory class method.
  # 
  # @param [#to_s] name
  #   The name of the type. Will be normalized to a string via it's `#to_s`
  #   method. 
  # 
  # @param [Enumerable<#to_s>] aliases
  #   Aliases to add for the type factory method. Normalized to a {Set} of
  #   strings before use.
  # 
  # @param [nil | Proc<(s:String): MEMBER>] from_s
  #   Optional function to load type members from strings.
  # 
  # @param [Boolean] maybe
  #   When `true` will add `?`-suffixed versions of the factory that 
  #   create {.Maybe} versions of the type.
  # 
  # @param [nil | false | Proc<(*args, &block): String>] default_name
  #   
  #   Controls what - if anything - is done with the `name:` value in 
  #   `options` when the factory method is called.
  #   
  #   Everything here is done *before* the `options` are passed to the 
  #   factory method's `&body`, so the body will see any `name:` option that
  #   is filled in.
  #   
  #   When...
  #   
  #   -   `nil` - when...
  #       -   `parameterize:` is `nil` - `name` will be used as the created
  #           type's {Type#name} unless a `name:` option is explicitly 
  #           provided by the factory caller.
  #           
  #           This situation covers "static" types that will only differ by
  #           their `options` - things like custom {Type#from_s},
  #           {Type#to_data}, etc.. Really, these are more like aliases since 
  #           their member sets are identical.
  #           
  #       -   `parameterize:` is *not* `nil` - the `name:` option will be left
  #           as `nil` if none is provided by the factory caller.
  #           
  #   -   `false` - the `name:` option will not be touched - it will stay `nil`
  #       unless the factory caller provides a value.
  #       
  #   -   `Proc<(*args, &block)->String>` - when the factory caller does not
  #       provide a `name:` option this function will be called with the
  #       arguments (including `options`) and block (if any) that the 
  #       factory method was called with, and is expected to return a {String}
  #       that will be set as the `name:` option.
  # 
  # @param [nil | Symbol | Array<Symbol>] parameterize
  #   Indicates if the type is parameterized, and, if so, what arguments
  #   it's parameterized over.
  #   
  #   Right now, just prevents the `name:` being assigned as the type's name
  #   when one isn't specified (see the `default_name:` parameter a 
  #   complete(-ly confusing) explanation.
  #   
  #   The hope was to use this for something useful in the future, but who the
  #   hell knows to be honest.
  #   
  # @param [nil | String | Proc<(*args, &block): String>] symbolic
  #   Controls what's done with the `symbolic:` option - which affects what
  #   the new type's {Type#symbolic} will return - when the factory methods
  #   are called with the `symbolic:` option `nil` or missing:
  #   
  #   -   `nil` - nothing changes. `nil` goes in to the type initialization
  #       method, and should end up as a `symbolic: nil` option in 
  #       {Type#initialize}.
  #       
  #   -   `String` - This value is used. Makes sense for `static` types
  #       who only accept options that don't affect the members of the types
  #       they produce.
  #       
  #   -   `Proc<(*args, &block)->String>` - Gets called with the arguments 
  #       (including `options`) and block (if any) the factory method is called
  #       with and is expected to return the symbolic string representation.
  # 
  # @param [nil | Proc<(MEMBER): DATA>] to_data
  #   I'm getting tired of writing this shit so I'm going to be brief here -
  #   provides a value that will get set as the `to_data:` option and become
  #   responsible for turning type member values into "data" (think things
  #   you can JSON encode).
  # 
  # @param [Proc] body
  #   The type factory method body. **MUST** return a {Type} instance.
  # 
  # @return [nil]
  #   Just creates class methods on whatever it's mixed in to.
  # 
  def def_type  name,
                aliases: [],
                from_s: nil,
                maybe: true,
                default_name: nil,
                parameterize: nil,
                symbolic: nil,
                to_data: nil,
                &body
    # Normalize to strings
    name = name.to_s
    aliases = aliases.map( &:to_s ).to_set

    unless  default_name.nil? ||
            default_name == false ||
            default_name.is_a?( Proc )
      raise NRSER::TypeError,
        "`default_name:` keyword argument must be {nil}, {false} or a {Proc},",
        "found", default_name,
        expected: [ nil, false, Proc ],
        received: default_name
    end

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

      # If `default_name` is {false} it means we don't fuck with the name at
      # all, and if it's not `nil` it's been user-set.
      if options[:name].nil? && default_name != false
        if default_name.is_a? Proc
          options[:name] = default_name.call *args, &block
        
        # The "old" (like, two days ago) way of signalling not to write `name`
        # in (before we had `default_name=false`) was to tell {#def_type} that
        # you were parameterizing, in which case it wouldn't make any sense 
        # to write `name` in for all the types coming out.
        # 
        # And it still doesn't, though - despite high hopes for a future of 
        # parameterized enlightenment - that's all we've been using 
        # `parameterize` for at the time, and there will def be some argument
        # structure kinks to work out in order to actually do something useful
        # with the information, though I'm sure that is solvable.
        # 
        # So I'm saying I wouldn't be surprised if `parameterize` ended up 
        # never really going anywhere except away.
        elsif parameterize.nil?
          options[:name] = name

        end
      end # if options[:name].nil? && default_name != false

      options[:from_s] ||= from_s

      options[:symbolic] ||= case symbolic
      when Proc
        symbolic.call *args, &block
      else
        symbolic
      end

      options[:to_data] ||= to_data
      
      body.call( *args, **options, &block ).tap { |type|
        unless type.is_a? Type
          raise NRSER::TypeError.new \
            "Type factory method #{ self.safe_name }.#{ __method__ } did",
            "not return a {NRSER::Types::Type}! All type factory methods",
            "**MUST** always return type instances. This method needs to be",
            "fixed."
        end
      }
    end

    underscored = name.underscore

    # Underscored names are also available!
    unless  name == underscored ||
            aliases.include?( underscored )
      aliases << underscored
    end
    
    aliases.each do |alias_name|
      if self.respond_to? alias_name
        alias_name = alias_name.to_s + '_'
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
        maybe_alias_name = "#{ alias_name }?"

        if self.respond_to? maybe_alias_name
          maybe_alias_name = "#{ alias_name }_?"
        end

        singleton_class.send :alias_method, maybe_alias_name, maybe_name
      end
      
    end

    nil
  end # #def_type

  
end # module Factory


# /Namespace
# =======================================================================

end # module Types
end # module NRSER

