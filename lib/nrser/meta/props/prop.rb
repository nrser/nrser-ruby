require 'nrser/no_arg'

require 'nrser/refinements'
require 'nrser/refinements/types'

using NRSER::Types

module NRSER 
module Meta
module Props
  
class Prop
  attr_accessor :defined_in,
                :name,
                :type,
                :source
  
  
  def initialize  defined_in,
                  name,
                  type: t.any,
                  default: NRSER::NO_ARG,
                  source: nil
    
    @defined_in = defined_in
    @name = name
    @type = t.make type
    @source = source
    @default = default
    
    if @source.nil?
      @instance_variable_source = false
    else
      source_str = source.to_s
      @instance_variable_source = source_str[0] == '@'
    end
  end
  
  
  # @todo Document default? method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def default?
    @default != NRSER::NO_ARG
  end # #default?
  
  
  def default
    if default?
      @default
    else
      raise NameError.new NRSER.squish <<-END
        Prop #{ self } has no default value.
      END
    end
  end
  
  
  # @todo Document source? method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def source?
    !@source.nil?
  end # #source?
  
  
  # @todo Document instance_variable_source? method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def instance_variable_source?
    @instance_variable_source
  end # #instance_variable_source?
  
  
  # @todo Document primary? method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def primary?
    !source?
  end # #primary?
  
  
  # @todo Document get method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def get instance
    if source?
      if instance_variable_source?
        instance.instance_variable_get source
      else
        instance.send source
      end
    else
      values(instance)[name]
    end
  end # #get
  
  
  # @todo Document set method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def set instance, value
    unless type.test value
      raise TypeError.new NRSER.squish <<-END
        #{ defined_in }##{ name } must be of type #{ type };
        found #{ value.inspect }
      END
    end
    
    values(instance)[name] = value
  end # #set
  
  
  
  # @todo Document set_from_hash method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def set_from_values_hash instance, **values
    if values.key? name
      set instance, values[name]
    else
      if default?
        set instance, default.dup
      else
        raise TypeError.new NRSER.squish <<-END
          Prop #{ name } has no default value and no value was provided in
          values #{ values.inspect }.
        END
      end
    end
  end # #set_from_hash
  
  
  private
    
    # @todo Document values method.
    # 
    # @param [type] arg_name
    #   @todo Add name param description.
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def values instance
      unless instance.instance_variable_defined? PROP_VALUES_VARIABLE_NAME
        instance.instance_variable_set PROP_VALUES_VARIABLE_NAME, {}
      end
      
      instance.instance_variable_get PROP_VALUES_VARIABLE_NAME
    end # #value
  
end # class Prop
  
end # module Props
end # module Meta
end # module NRSER