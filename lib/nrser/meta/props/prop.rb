require 'nrser/no_arg'

require 'nrser/refinements'
using NRSER

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
                  source: nil,
                  to_data: nil
    
    @defined_in = defined_in
    @name = name
    @type = t.make type
    @source = source
    @default = default
    @to_data = to_data
    
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
        case source
        when String, Symbol
          instance.send source
        when Proc
          instance.instance_exec &source
        else
          raise TypeError.squished <<-END
            Expected `Prop#source` to be a String, Symbol or Proc;
            found #{ source.inspect }
          END
        end
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
  
  
  # Get the "data" value - a basic scalar or structure of hashes, arrays and
  # scalars, suitable for JSON encoding, etc. - for the property from an
  # instance.
  # 
  # The process depends on the `to_data:` keyword provided at property
  # declaration:
  # 
  # 1.  {nil} *default*
  #     -   If the property value responds to `#to_data`, the result of 
  #         invoking that method will be returned.
  #         
  #         **WARNING**
  #         
  #         This can cause infinite recursion if an instance has
  #         a property value that is also an instance of the same class (as
  #         as other more complicated scenarios that boil down to the same 
  #         problem), but, really, what else would it do in this situation?
  #         
  #         This problem can be avoided by by providing a `to_data:` keyword
  #         when declaring the property that dictates how to handle it's value.
  #         In fact, that was the motivation for adding `to_data:`.
  #         
  #     -   Otherwise, the value itself is returned, under the assumption that
  #         it is already suitable as data.
  #         
  # 2.  {Symbol} | {String}
  #     -   The `to_data:` string or symbol is sent to the property value
  #         (the method with this name is called via {Object#send}).
  #         
  # 3.  {Proc}
  #     -   The `to_data:` proc is called with the property value as the sole
  #         argument and the result is returned as the data.
  # 
  # @param [NRSER::Meta::Props] instance
  #   Instance to get the property value form.
  # 
  # @return [Object]
  #   Data representation of the property value (hopefully - the value itself
  #   is returned if we don't have any better options, see above).
  # 
  # @raise [TypeError]
  #   If {@to_data} (provided via the `to_data:` keyword at property 
  #   declaration) is anything other than {nil}, {String}, {Symbol} or {Proc}.
  # 
  def to_data instance
    value = get instance
    
    case @to_data
    when nil
      if value.respond_to? :to_data
        value.to_data
      elsif type.respond_to? :to_data
        type.to_data value
      else
        value
      end
    when Symbol, String
      value.send @to_data
    when Proc
      @to_data.call value
    else
      raise TypeError.squished <<-END
        Expected `@to_data` to be Symbol, String or Proc;
        found #{ @to_data.inspect }
      END
    end
  end # #to_data
  
  
  # @return [String]
  #   a short string describing the instance.
  # 
  def to_s
    <<-END.squish
      #<#{ self.class.name }
        #{ @defined_in.name }##{ @name }:#{ @type }>
    END
  end # #to_s  
  
  
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