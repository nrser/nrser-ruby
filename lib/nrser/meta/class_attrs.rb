module NRSER 
module Meta
  
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
module ClassAttrs 
  
  # Class methods to extend the receiver with when {NRSER::ClassAttrs}
  # is included.
  module ClassMethods
    def instance_variable_lookup name
      instance_variable_get(name) || if (
        superclass.respond_to? :instance_variable_lookup
      )
        superclass.instance_variable_lookup name
      else
        raise NoMethodError.new NRSER.squish <<-END
          #{ name.inspect } is not defined anywhere in the class hierarchy
        END
      end
    end

    def class_attr_accessor attr
      var_name = "@#{ attr }".to_sym
      
      singleton_class.class_eval do
        define_method(attr) do |*args|
          case args.length
          when 0
            instance_variable_lookup var_name
          when 1
            instance_variable_set var_name, args[0]
          else
            raise ArgumentError.new NRSER.squish <<-END
              wrong number of arguments
              (given #{ args.length }, expected 0 or 1)
            END
          end
        end
        
        define_method("#{ attr }=") do |value|
          instance_variable_set var_name, value
        end
      end
    end
  end # module ClassMethods
  
  # Extend the including class with
  # {QB::Util::ClassInstanceMethods::ClassMethods}
  def self.included base
    base.extend ClassMethods
  end
  
end # module ClassAttrs

end # module Meta
end # module NRSER
