# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/no_arg'


# Namespace
# =======================================================================

module  NRSER
module  Meta


# Definitions
# =======================================================================


# Mixin to provide methods to define and access class attributes - variables
# that act like instance variables with regards to inheritance but for the
# class itself.
# 
# The motivation is to create a easy-to-use class instance variables that
# resolve like regular instance variables by looking up the inheritance
# hierarchy - meaning that:
# 
# 1.  When the value is set, it is set on the class in which the operation
#     happens.
#     
# 2.  That value is read for that class and any subclasses.
#     -   Class 'self' attr_accessor values are not visible to subclasses.
#     
# 3.  But that value is not visible to any classes further up the inheritance
#     chain.
#     -   Class variables (`@@` variables) are global to the *entire class
#         hierarchy* rooted at the definition point.
# 
# The tests in `spec/nrser/class_attrs_spec.rb` provide detailed walk-through
# of usage and differences from other approaches.
# 
module NRSER::Meta::ClassAttrs
  
  # Class methods to extend the receiver with when {NRSER::Meta::ClassAttrs}
  # is included.
  module ClassMethods
    def instance_variable_lookup  name,
                                  default: NRSER::NO_ARG,
                                  default_from: NRSER::NO_ARG
      
      # If it's defined here on self, return that
      if instance_variable_defined? name
        return instance_variable_get name
      end
      
      # Ok, now to need to look for it.
      
      # See if the superclass has the lookup method
      if superclass.respond_to? :instance_variable_lookup
        # It does. See what we get from that. We create a new object to use
        # as a flag and assign it to `default` so we can tell if the search
        # failed.
        not_found = Object.new
        result = superclass.instance_variable_lookup name, default: not_found
        
        # If we found something, return it.
        return result unless result == not_found
        
      end # if superclass.respond_to? :instance_variable_lookup
      
      # Ok, nothing was found.
      
      # See if we can use a default...
      if default != NRSER::NO_ARG || default_from != NRSER::NO_ARG
        # We can use a default.
        # `default` takes precedence.
        if default != NRSER::NO_ARG
          default
        else
          send default_from
        end
        
      else
        # Nope, we can't, raise.
        raise NoMethodError,
          "#{ name.inspect } is not defined anywhere in the class hierarchy"

      end # if we have a default value / else
      
    end # #instance_variable_lookup
    

    def class_attr_accessor attr,
                            default: NRSER::NO_ARG,
                            default_from: NRSER::NO_ARG,
                            write_once: false
      
      var_name = "@#{ attr }".to_sym
      
      singleton_class.class_eval do
        define_method(attr) do |*args|
          case args.length
          when 0
            instance_variable_lookup  var_name,
                                      default: default,
                                      default_from: default_from
          when 1
            if write_once && instance_variable_defined?( var_name )
              raise NRSER::ConflictError.new \
                attr, "can only be written once (typically as part of",
                "configuration)",
                current_value: instance_variable_get( var_name )
            end
            
            instance_variable_set var_name, args[0]
          else
            raise NRSER::ArgumentError.new \
              "wrong number of arguments (given", args.length,
              "expected 0 or 1)"
          end
        end
        
        define_method("#{ attr }=") do |value|
          if write_once && instance_variable_defined?( var_name )
            raise NRSER::ConflictError.new \
              attr, "can only be written once (typically as part of",
              "configuration)",
              current_value: instance_variable_get( var_name )
          end
          
          instance_variable_set var_name, value
        end
      end
    end # class_attr_accessor
    
    
    def class_attr *args
      class_attr_accessor *args
    end # class_attr
    
    
    def class_attr_writer attr
      var_name = "@#{ attr }".to_sym
      
      singleton_class.class_eval do
        define_method("#{ attr }=") do |value|
          instance_variable_set var_name, value
        end
      end
    end # #class_attr_writer
    
  end # module ClassMethods
  
  # Extend the including class with {NRSER::Meta::ClassAttrs::ClassMethods}
  def self.included base
    base.extend ClassMethods
  end
  
end # module ClassAttrs

# /Namespace
# =======================================================================

end # module Meta
end # module NRSER
