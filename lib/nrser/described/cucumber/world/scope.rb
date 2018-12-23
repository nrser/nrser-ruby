# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# We set scope modules as constants on
# {NRSER::Described::Cucumber::ScenarioScopes}
require 'nrser/described/cucumber/scenario_scopes'


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  World


# Definitions
# =======================================================================

# Helpers for using a dynamic {#scope} - a {::Module} that gets created on
# demand for loading feature code, and methods to resolve objects for use.
# 
module Scope
  
  # What we name the current {#scope} {::Module}.
  #
  # The name is simply unique, allowing it to be used as a constant name.
  # There's no useful information in it (some day maybe).
  #
  # All we need is something unique to the "step instance" (or whatever you want
  # to call the instances that steps execute in), and `#object_id` should work
  # just fine (we stick "Scenario" in front of it to make it a legit constant
  # name).
  #
  # @example
  #   scope_const_name #=> "Scenario70297130632340"
  #
  # @return [::String]
  #
  def scope_const_name
    "Scenario#{ object_id }"
  end
  
  
  # The current scope {::Module}. Created on demand.
  # 
  # @return [::Module]
  # 
  def scope
    @scope ||= ScenarioScopes.const_set scope_const_name, ::Module.new
  end # #scope
  
  
  # Resolve a constant from the {#scope} or globally.
  # 
  # Adapted from ActiveSupport 
  # https://github.com/rails/rails/blob/96dee0e7e5a8dd6ce42999b13d0bd0623073e229/activesupport/lib/active_support/inflector/methods.rb#L272
  # 
  # @param [::String] name
  #   The name of the constant to resolve.
  # 
  # @return [Object]
  # 
  def resolve_const name
    names = name.split '::'
    
    # Trigger a built-in NameError exception including the ill-formed constant in the message.
    Object.const_get(camel_cased_word) if names.empty?

    # Remove the first blank element in case of '::ClassName' notation.
    starting_point = if names.size > 1 && names.first.empty?
      names.shift
      ::Object
    else
      scope
    end

    names.inject(starting_point) do |constant, name|
      if constant == Object
        constant.const_get(name)
      else
        candidate = constant.const_get(name)
        next candidate if constant.const_defined?(name, false)
        next candidate unless Object.const_defined?(name)

        # Go down the ancestors to check if it is owned directly. The check
        # stops when we reach Object or the end of ancestors tree.
        constant = constant.ancestors.inject(constant) do |const, ancestor|
          break const    if ancestor == Object
          break ancestor if ancestor.const_defined?(name, false)
          const
        end

        # owner is in Object, so raise
        constant.const_get(name, false)
      end
    end
  end # #resolve_const
  
  
  # Helper that resolves a constant, first from the {#scope}, then globally, and
  # checks that it "is a" {::Class} or {::Module} (that `resolve_const( name
  # ).is_a? cls` is `true`).
  # 
  # @see #resolve_const
  # @see #resolve_class
  # @see #resolve_module
  # 
  # @param [::Module] cls
  #   Class (or module) that the resolved constant must be a kind of.
  # 
  # @param name (see #resolve_const)
  # 
  # @return [::Object]
  # 
  # @raise [NRSER::TypeError]
  #   If the const resolved from `name` is not a `cls`.
  #   
  def resolve_kind_of cls, name
    resolve_const( name ).tap do |const|      
      unless const.is_a? cls
        raise NRSER::TypeError.new \
          "Resolved name", name.inspect, "but it's not a", cls,
          name: name,
          resolved_const: const
      end
    end
  end
  
  
  # Resolve a name from {#scope}/globally to a {::Module} or raise.
  #
  # @note
  #   Remember that {::Class} are {::Module}, so this will work to resolve 
  #   classes as well.
  #
  # @param [::String] module_name
  #   What it sounds like.
  #
  # @return [::Module]
  # 
  # @raise [NRSER::TypeError]
  #   If the resolved constant is not a {::Module}.
  # 
  def resolve_module module_name
    resolve_kind_of ::Module, module_name
  end
  
  
  # Resolve a name from {#scope}/globally to a {::Class} or raise.
  #
  # @param [::String] class_name
  #   What it sounds like.
  #
  # @return [::Class]
  # 
  # @raise [NRSER::TypeError]
  #   If the resolved constant is not a {::Class}.
  # 
  def resolve_class class_name
    resolve_kind_of ::Class, class_name
  end
  
end # module Scope


# /Namespace
# =======================================================================

end # module World
end # module Cucumber
end # module Described
end # module NRSER
