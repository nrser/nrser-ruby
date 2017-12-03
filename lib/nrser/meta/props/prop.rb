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

require 'nrser/refinements'
using NRSER

require 'nrser/refinements/types'
using NRSER::Types


# Declarations
# =======================================================================

module NRSER; end
module NRSER::Meta; end
module NRSER::Meta::Props; end


# Definitions
# =======================================================================

# `Prop` instances hold the configuration for a property defined on propertied
# classes.
# 
# Props are immutable by design.
# 
class NRSER::Meta::Props::Prop
  
  # The class the prop was defined in.
  # 
  # @return [Class]
  #     
  attr_reader :defined_in
  
  
  # The name of the prop, which is used as it's method name and key where
  # applicable.
  # 
  # @return [Symbol]
  #     
  attr_reader :name
  
  
  # The type of the valid values for the property.
  # 
  # @return [NRSER::Types::Type]
  #     
  attr_reader :type
  
    
  # Optional name of instance variable (including the `@` prefix) or getter
  # method (method that takes no arguments) that provides the property's
  # value.
  # 
  # Props that have a source are considered *derived*, those that don't are 
  # called *primary*.
  # 
  # @return [Symbol | String]
  #     
  attr_reader :source
  
  
  # Constructor
  # =====================================================================
  
  # Instantiate a new `Prop` instance.
  # 
  # You should not need to construct a `Prop` directly unless you are doing
  # custom meta-programming - they should be constructed for you via the
  # `.prop` "macro" defined at {NRSER::Meta::Props::ClassMethods#prop}
  # that is extended in to classes including {NRSER::Meta::Props}.
  # 
  def initialize  defined_in,
                  name,
                  type: t.any,
                  default: nil,
                  default_from: nil,
                  source: nil,
                  to_data: nil,
                  from_data: nil
    
    # Set these up first so {#to_s} works in case we need to raise errors.
    @defined_in = defined_in
    @name = name
    @type = t.make type
    
    @to_data = to_data
    @from_data = from_data
    
    # Source
    
    @source = source # TODO fix this: t.maybe( t.label ).check source
    
    # Detect if the source 
    if source.nil?
      @instance_variable_source = false
    else
      # TODO Check that default and default_from are `nil`, make no sense here
      
      source_str = source.to_s
      @instance_variable_source = source_str[0] == '@'
    end
    
    # Defaults
    
    # Can't provide both default and default_from
    unless default.nil? || default_from.nil?
      raise NRSER::ConflictError.new binding.erb <<-ERB
        Both `default:` and `default_from:` keyword args provided when 
        constructing <%= self %>. At least one must be `nil`.
        
        default:
            <%= default.pretty_inspect %>
        
        default_from:
            <%= default_from.pretty_inspect %>
        
      ERB
    end
    
    if default_from.nil?
      # We are going to use `default`
          
      # Validate `default` value
      if default.nil?
        # If it's `nil` we still want to see if it's a valid value for the type
        # so we can report if this prop has a default value or not.
        # 
        # However, we only need to do that if there is no `source`
        # 
        @has_default = if source.nil?
          @type.test default
        else
          # NOTE  This is up for debate... does a derived property have a 
          #       default? What does that even mean?
          true # false ?
        end
        
      else
        # Check that the default value is valid for the type, raising TypeError
        # if it isn't.
        @type.check( default ) { |type:, value:|
          binding.erb <<-ERB
            Default value is not valid for <%= self %>:
            
                <%= value.pretty_inspect %>
            
          ERB
        }
        
        # If we passed the check we know the value is valid
        @has_default = true
        
        # Set the default value to `default`, freezing it since it will be 
        # set on instances without any attempt at duplication, which seems like
        # it *might be ok* since a lot of prop'd classes are being used
        # immutably.
        @default_value = default.freeze
      end
      
    else
      # `default_from` is not `nil`, so we're going to use that.
      
      # This means we "have" a default since we believe we can use it to make
      # one - the actual values will have to be validates at that point.
      @has_default = true
      
      # And set it.
      # 
      # TODO validate it's something reasonable here?
      # 
      @default_from = default_from
    end
    
  end # #initialize
  
  
  # Full name with class prop was defined in.
  # 
  # @example
  #   MyMod::SomeClass.props[:that_prop].full_name
  #   # => 'MyMod::SomeClass#full_name'
  # 
  # @return [String]
  # 
  def full_name
    "#{ defined_in.name }##{ name }"
  end # #full_name
  
  
  # Test if this prop is configured to provide default values - 
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def has_default?
    @has_default
  end # #has_default?
  
  # Old name
  alias_method :default?, :has_default?
  
  
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
    type.check( value ) do
      binding.erb <<-END
        Value of type <%= value.class.name %> for prop <%= self.full_name %> 
        failed type check.
        
        Must satisfy type:
        
            <%= type %>
        
        Given value:
        
            <%= value.pretty_inspect %>
        
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
        # set instance, if !default.nil? && default.respond_to?( :dup )
        #   default.dup
        # else
        #   default
        # end
        set instance, default
      else
        raise TypeError.new binding.erb <<-ERB
          Prop <#= full_name %> has no default value and no value was provided 
          in values:
          
              <%= values.pretty_inspect %>
          
        ERB
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
  
  
  # @todo Document value_from_data method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def value_from_data data
    value = case @from_data
    when nil
      # This {Prop} does not have any custom `from_data` instructions, which
      # means we must rely on the {#type} to covert *data* to a *value*.
      # 
      if type.has_from_data?
        type.from_data data
      else
        data
      end
      
    when Symbol, String
      # The custom `from_data` configuration specifies a string or symbol name,
      # which we interpret as a class method on the defining class and call
      # with the data to produce a value.
      @defined_in.send @to_data, data
    
    when Proc
      # The custom `from_data` configuration provides a procedure, which we
      # call with the data to produce the value.
      @from_data.call data
      
    else
      raise TypeError.new binding.erb <<-ERB
        Expected `@from_data` to be Symbol, String or Proc;
        found <%= @from_data.class %>.
        
        Acceptable types:
        
        -   Symbol or String
            -   Name of class method on the class this property is defined in
                (<%= @defined_in %>) to call with data to convert it to a
                property value.
                
        -   Proc
            -   Procedure to call with data to convert it to a property value.
        
        Found `@from_data`:
        
            <%= @from_data.pretty_inspect %>
        
        (type <%= @from_data.class %>)
        
      ERB
    end
      
  end # #value_from_data
  
  
  # @return [String]
  #   a short string describing the instance.
  # 
  def to_s
    "#<#{ self.class.name } #{ full_name }:#{ type }>"
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
      unless instance.instance_variable_defined?(
        NRSER::Meta::Props::PROP_VALUES_VARIABLE_NAME
      )
        instance.instance_variable_set \
          NRSER::Meta::Props::PROP_VALUES_VARIABLE_NAME, {}
      end
      
      instance.instance_variable_get \
        NRSER::Meta::Props::PROP_VALUES_VARIABLE_NAME
    end # #value
  
end # class NRSER::Meta::Props::Prop
