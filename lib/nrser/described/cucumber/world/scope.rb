# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Deps ###

require "active_support/core_ext/hash/indifferent_access"

### Project / Package ###

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
  
  
  # Get a {::Binding} from the {#scope}, with the {#let_bindings} added as 
  # local variables.
  # 
  # This allows evaluating code in the binding that naturally closes around the 
  # let values.
  # 
  # @return [::Binding]
  # 
  def scope_binding
    scope.module_eval( 'binding' ).tap do |binding|
      let_bindings.each do |name, value|
        binding.local_variable_set name, value
      end
    end
  end
  
  
  # Evaluate a string of Ruby code in the {#scope_binding}, which is where you
  # want to do all your evaluations, because it has the {#let_bindings} added
  # as local variables.
  # 
  # @param [::String] string
  #   Ruby code.
  # 
  # @return [::Object]
  #   Result of the evaluation.
  # 
  def scope_eval string
    scope_binding.eval string
  end
  
  
  # Map of names to values bound by {#let}.
  # 
  # Uses a {::HashWithIndifferentAccess} so values can be retrieved by 
  # {::String} or {::Symbol} names.
  # 
  # @return [::HashWithIndifferentAccess]
  # 
  def let_bindings
    @let_bindings ||= ::HashWithIndifferentAccess.new
  end
  
  
  def resolve_let name
    name = name.to_s unless name.is_a?( ::String )
    
    if let_bindings.key? name
      let_bindings[ name ]
    else
      raise ::NoMethodError,
        "No let value bound to '#{ name }'"
    end
  end
  
  
  # Add a local variable binding that will be present in {#scope_binding}, 
  # which is the {::Binding} used in {#scope_eval}.
  # 
  # @param [#to_s] name
  #   Name of the local variable. No checks are done here, but an error will be
  #   raised when {#scope_binding} tries to use it if it's not valid.
  # 
  # @param [::Object] value
  #   Value to bind to the `name`.
  # 
  # @return [::Object]
  #   The `value`.
  # 
  def let name, value
    let_bindings[ name.to_s ] = value
  end
  
  
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
    const_name = Meta::Names::Const.new name
    
    # Trigger a built-in NameError exception including the ill-formed constant
    # in the message.
    Object.const_get( const_name ) if const_name.segments.empty?
    
    starting_points = if const_name.absolute?
      [ ::Object ]
    else
      [ scope, ::Object ]
    end
    
    starting_points.each do |starting_point|
      begin
        return resolve_const_from const_name, starting_point
      rescue NameError => error
        # pass
      end
    end # starting_points.each
    
    raise NameError.new \
      "Unable to resolve constant {#{ const_name }}"
  end # #resolve_const
  
  
  private
  # ========================================================================
    
    def resolve_const_from const_name, starting_point
      const_name.
        segments.
        reduce starting_point do |constant, const_name_segment|
          candidate = constant.const_get const_name_segment
          
          # If the constant is {::Object} then we're good to continue with the 
          # candidate (since we don't have to think about inheritance..?)
          next candidate if constant == ::Object
          
          # If the candidate was a constant in the constant *itself* (not inherited)
          # then we're good
          next candidate if constant.const_defined?( const_name_segment, false )
          
          # Also... if the candidate is *not* a constant defined in {::Object}
          # then we're gonna use it..?
          next candidate unless ::Object.const_defined?( const_name_segment )
          
          # So... now we know it's defined in {::Object}..?
          
          # Go down the ancestors to check if it is owned directly. The check
          # stops when we reach Object or the end of ancestors tree.
          constant = constant.ancestors.reduce constant do |constant, ancestor|
            # If we've iterated ancestors until we hit {::Object}, so assign the
            # current constant
            break constant if ancestor == ::Object
            
            # We found an ancestor that has the const, so assign that
            break ancestor if ancestor.const_defined?( const_name_segment, false )
            
            # Just keep going with the current constant. If this is the end of the
            # ancestors, and we never found the constant or hit {::Object} then this
            # value - which *is* the same as the constant before we started - will 
            # be stuck back in constant
            constant
          end
          
          # "owner is in Object, so raise" - huh? I don't get that... does this 
          # **always** raise? Is all the work up there just to do this?
          constant.const_get const_name_segment, false
        end # reduce
    end # #resolve_const_from
  
  public # end private *****************************************************
  
  
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
