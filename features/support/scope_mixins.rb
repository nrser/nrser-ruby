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


# Namespace
# =======================================================================


# Definitions
# =======================================================================

module Scopes
end

# Helpers for using a dynamic {#scope} - a {::Module} that gets created on
# demand for loading feature code, and methods to resolve objects for use.
# 
module ScopeMixin
  
  
  def scope_const_name
    "Scenario#{ object_id }"
  end
  
  
  # @todo Document scope method.
  # 
  # @return [::Module]
  # 
  def scope
    @scope ||= Scopes.const_set scope_const_name, Module.new
  end # #scope
  
  
  # Resolve a constant from the {#scope} or globally.
  # 
  # Adapted from ActiveSupport 
  # https://github.com/rails/rails/blob/96dee0e7e5a8dd6ce42999b13d0bd0623073e229/activesupport/lib/active_support/inflector/methods.rb#L272
  # 
  # @param [String] string
  # 
  # @return [Object]
  # 
  def resolve_const string
    names = string.split '::'
    
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
  
  
  def resolve_class class_name
    const = resolve_const class_name
    
    unless const.is_a? ::Class
      raise NRSER::TypeError.new \
        "Resolved name", class_name.inspect, "but it's not a {::Class}",
        class_name: class_name,
        resolved_const: const
    end
    
    const
  end
  
end # module ScopeMixin


# /Namespace
# =======================================================================