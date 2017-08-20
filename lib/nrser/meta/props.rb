module NRSER 
module Meta 

T = NRSER::Types

# 
module Props
  PROPS_VARIABLE_NAME = :@__NRSER_props
  PROP_VALUES_VARIABLE_NAME = :@__NRSER_prop_values
  
  class Prop
    attr_accessor :defined_in,
                  :name,
                  :type,
                  :source
    
    
    def initialize  defined_in,
                    name,
                    type: T.any,
                    default: NRSER::NO_ARG,
                    source: nil
      
      @defined_in = defined_in
      @name = name
      @type = NRSER::Types.make type
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
  
  
  # @todo Document get_props_ref method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.get_props_ref klass
    unless klass.instance_variable_defined? PROPS_VARIABLE_NAME
      klass.instance_variable_set PROPS_VARIABLE_NAME, {}
    end
    
    klass.instance_variable_get PROPS_VARIABLE_NAME
  end # .get_props_ref
  
  
  module ClassMethods
    
    
    # @todo Document props method.
    # 
    # @param [type] arg_name
    #   @todo Add name param description.
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def props own: false, primary: false
      result = if !own && superclass.respond_to?(:props)
        superclass.props own: own, primary: primary
      else
        {}
      end
      
      own_props = NRSER::Meta::Props.get_props_ref self
      
      if primary
        own_props.each {|name, prop|
          if prop.primary?
            result[name] = prop
          end
        }
      else
        result.merge! own_props
      end
      
      result
    end # #own_props
    
    
    # @todo Document prop method.
    # 
    # @param [type] arg_name
    #   @todo Add name param description.
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def prop name, **opts
      ref = NRSER::Meta::Props.get_props_ref self
      
      T.sym.check name
      
      if ref.key? name
        raise ArgumentError.new NRSER.squish <<-END
          Prop #{ name.inspect } already set for #{ self }:
          #{ ref[name].inspect }
        END
      end
      
      prop = Prop.new self, name, **opts
      ref[name] = prop
      
      unless prop.source?
        class_eval do
          define_method(name) do
            prop.get self
          end
          
          # protected
          #   define_method("#{ name }=") do |value|
          #     prop.set self, value
          #   end
        end
      end
    end # #prop
    
    
    
    # @todo Document from_h method.
    # 
    # @param [type] arg_name
    #   @todo Add name param description.
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def from_h hash
      self.new(
        NRSER.slice_keys(
          NRSER.symbolize_keys(hash),
          *self.props(primary: true).keys
        )
      )
    end # #from_h
    
      
  end # module ClassMethods
  
  
  # Extend the including class with {NRSER::Meta::Props:ClassMethods}
  def self.included base
    base.extend ClassMethods
  end
  
  
  # Instance Methods
  # =====================================================================
  
  
  # @todo Document initialize_props method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def initialize_props values
    self.class.props(primary: true).each { |name, prop|
      prop.set_from_values_hash self, values
    }
  end # #initialize_props
  
  
  # @todo Document to_h method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def to_h primary: false, own: false
    NRSER.map_values(
      self.class.props own: own, primary: primary
    ) { |name, prop| prop.get self }
  end # #to_h
  
  
  # @todo Document to_json method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def to_json *args
    to_h.to_json *args
  end # #to_json
  
  
  def to_yaml *args
    to_h.to_yaml *args
  end
  
  
end # module Props

end # module Meta
end # module NRSER

require_relative './props/base'
