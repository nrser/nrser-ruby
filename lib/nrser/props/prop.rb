# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------
require 'nrser/refinements/types'


# Refinements
# =======================================================================

using NRSER::Types


# Namespace
# =======================================================================

module NRSER
module Props


# Definitions
# =======================================================================

# `Prop` instances hold the configuration for a property defined on propertied
# classes.
# 
# Props are immutable by design.
# 
class Prop
  
  # Mixins
  # ========================================================================
  
  include NRSER::Log::Mixin
  
  
  # Attributes
  # ========================================================================
  
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
  
  
  # The key under which the value will be stored in the storage.
  # 
  # @return [nil | Integer]
  #     
  attr_reader :index
  
  
  # The type of the valid values for the property.
  # 
  # @return [NRSER::Types::Type]
  #     
  attr_reader :type
  
  
  # Names of any props this one depends on (to create a default).
  # 
  # @return [Array<Symbol>]
  #     
  attr_reader :deps
  
  
  # Optional name of instance variable (including the `@` prefix) or getter
  # method (method that takes no arguments) that provides the property's
  # value.
  # 
  # Props that have a source are considered *derived*, those that don't are
  # called *primary*.
  # 
  # @return [nil]
  #   When this prop is a *primary* property and receives it's value at
  #   initialization or from a {#default}.
  # 
  # @return [Symbol]
  #   This prop is *derived* by returning an instance variable if the symbol
  #   starts with `@` or otherwise by sending the symbol to the prop'd instance
  #   (calling that method with no arguments).
  # 
  # @return [Proc]
  #   This prop is *derived* by evaluating this {Proc} in the prop'd
  #   instance.
  #     
  attr_reader :source
  
  
  # TODO document `aliases` attribute.
  # 
  # @return [Array<Symbol>]
  #     
  attr_reader :aliases
  
  
  # Constructor
  # =====================================================================
  
  # Instantiate a new `Prop` instance.
  # 
  # You should not need to construct a `Prop` directly unless you are doing
  # custom meta-programming - they should be constructed for you via the
  # `.prop` "macro" defined at {NRSER::Props::Props::ClassMethods#prop}
  # that is extended in to classes including {NRSER::Props::Props}.
  # 
  # @param [nil | Proc | Object] default:
  #   A default value or a {Proc} used to get default values for *primary*
  #   props. *Dervied* props (those that have a {#source}) may not
  # 
  #   At least one of `default:` and `source:` must be `nil`.
  # 
  # @param [nil | Symbol | String | Proc] source:
  #   Source that provides the prop's value. See details for how each type is
  #   handled in {#source}. Strings are converted to symbols.
  #   
  #   At least one of `default:` and `source:` must be `nil`.
  # 
  # @raise [ArgumentError]
  #   If `default:` is not `nil` *and* `source:` is not `nil`.
  # 
  # @raise
  # 
  def initialize  defined_in,
                  name,
                  type: t.any,
                  default: nil,
                  source: nil,
                  to_data: nil,
                  from_data: nil,
                  index: nil,
                  reader: nil,
                  writer: nil,
                  aliases: []
    
    # Set these up first so {#to_s} works in case we need to raise errors.
    @defined_in = defined_in
    @name = t.sym.check name
    @index = t.non_neg_int?.check! index
    @type = t.make type
    
    # Will be overridden in {#init_default!} if needed
    @deps = []
    
    @to_data = to_data
    @from_data = from_data
    
    @reader, @writer = [ reader, writer ].map do |value|
      t.match value,
        t.bool?,
          value,
          
        t.hash_( keys: t.sym, values: t.bool ),
          :freeze.to_proc,
          
        t.hash_( keys: t.label, values: t.bool ),
          ->( hash ) { hash.map { |k, v| [ k.to_sym, v ] }.to_h.freeze }
    end
    
    @aliases = t.array( t.sym ).check! aliases
    
    # Source
    
    # normalize source to {nil}, {Symbol} or {Proc}
    @source = t.match source,
      nil,        nil,
      String,     ->( string ) { string.to_sym },
      Symbol,     source,
      Proc,       ->(){ source }
    
    # Detect if the source points to an instance variable (`:'@name'`-formatted
    # symbol).
    @instance_variable_source = \
      @source.is_a?( Symbol ) && @source.to_s[0] == '@'
    
    init_default! default
    
  end # #initialize
  
  
  protected
  # ========================================================================
    
    
    def init_default! default
      if default.nil?
        # If it's `nil`, we will use it as the default value *if* this
        # is a primary prop *and* the type is satisfied by `nil`
        @has_default = !source? && @type.test( default )
        return
      end
      
      # Now the we know that the default isn't `nil`, we want to check that
      # the prop doesn't have a source, because defaults don't make any sense
      # for sourced props
      if source?
        raise ArgumentError.new binding.erb <<-END
          Can not construct {<%= self.class.safe_name %>} with `default` and `source`
          
          Props with {#source} always get their value from that source, so
          defaults don't make any sense.
          
          Attempted to construct prop <%= name.inspect %> for class
          {<%= defined_in_name %>} with:
          
          default:
          
              <%= default.pretty_inspect %>
          
          source:
          
              <%= source.pretty_inspect %>
          
        END
      end
      
      if Proc === default
        case default.arity
        when 0
          # pass, no deps
        when 1
          # Check that it's valid and set deps
          @deps = default.parameters.map do |param|
            unless  Array === param &&
                    :keyreq == param[0]
              raise ArgumentError.new binding.erb <<~END
                Prop default Proc that take args must take only required
                keywords (`:keyreq` type)
                
                This is because this is how the props system figures out
                any dependency orders.
                
                Found:
                
                    <%= default.parameters %>
                
                For `default` for prop <%= full_name %>:
                
                    <%= self.pretty_inspect %>
                
              END
            end
            
            # The keyword name
            param[1]
          end
        else
          raise ArgumentError.new binding.erb <<~END
            Prop default Proc must take no params or only required keywords
            ({Proc#arity} of 0 or 1).
            
            Default to prop <%= full_name %> has arity <%= default.arity %>.
            
          END
        end
      
      elsif !default.frozen?
        raise ArgumentError.new binding.erb <<-END
          Non-proc default values must be frozen
        
          Default values that are *not* a {Proc} are shared between *all*
          instances of the prop'd class, and as such *must* be immutable
          (`#frozen? == true`).
          
          Found `default`:
          
              <%= default.pretty_inspect %>
          
          when constructing prop <%= name.inspect %>
          for class <%= defined_in_name %>
        END
      end
        
      @has_default = true
      @default = default
    end # #init_default!
    
  # end protected
  public
  
  
  # Instance Methods
  # ============================================================================
  
  def names
    [name, *aliases]
  end
  
  
  # Used by the {NRSER::Props::Props::ClassMethods.prop} "macro" method to
  # determine if it should create a reader method on the propertied class.
  # 
  # @param [Symbol] name
  #   The prop name or alias in question.
  # 
  # @return [Boolean]
  #   `true` if a reader method should be created for the prop value.
  # 
  def create_reader? name
    t.sym.check! name
    
    # If the options was explicitly provided then use that
    case @reader
    when nil
      # Fall through
    when Hash
      return @reader[name] if @reader.key? name
      # else fall through
    when true, false
      return @reader
    end
        
    # return @reader unless @reader.nil?
    
    # Always create readers for primary props
    return true if primary?
    
    # Don't override methods
    return false if defined_in.instance_methods.include?( name )
    
    # Create if {#source} is a {Proc} so it's accessible
    return true if Proc === source
    
    # Source is a symbol; only create if it's not the same as the name
    return source != name
  end # #create_reader?
  
  
  # Used by the {NRSER::Props::Props::ClassMethods.prop} "macro" method to
  # determine if it should create a writer method on the propertied class.
  # 
  # Right now, we don't create writers, but we will probably make them an
  # option in the future, which is why this stub is here.
  # 
  # @return [Boolean]
  #   Always `false` for the moment.
  # 
  def create_writer? name
    # If the options was explicitly provided then use that
    case @writer
    when nil
      # Fall through
    when Hash
      return @writer[name] if @writer.key? name
      # else fall through
    when true, false
      return @writer
    end
    
    storage_immutable = defined_in.metadata.storage.try( :immutable? )
    
    return !storage_immutable unless storage_immutable.nil?
    
    false
  end # #create_writer?
  
  
  def defined_in_name
    return defined_in.safe_name if defined_in.respond_to?( :safe_name )
    defined_in.to_s
  end
  
  
  # Full name with class prop was defined in.
  # 
  # @example
  #   MyMod::SomeClass.props[:that_prop].full_name
  #   # => 'MyMod::SomeClass#full_name'
  # 
  # @return [String]
  # 
  def full_name
    "#{ defined_in_name }##{ name }"
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
  
  
  # Get the default value for the property given the instance and values.
  # 
  # @todo
  #   This is a shitty hack stop-gap until I really figure our how this should
  #   work.
  # 
  # @param [Hash<Symbol, Object>] values
  #   Other prop values known at this point, keyed by name.
  # 
  # @return [Object]
  #   Default value.
  # 
  # @raise [NameError]
  #   If the prop doesn't have a default.
  # 
  def default **values
    if has_default?
      if Proc === @default
        case @default.arity
        when 0
          @default.call
        else
          kwds = values.slice *deps
          @default.call **kwds
        end
      else
        @default
      end
    else
      raise NameError.new binding.erb <<-END
        Prop <%= full_name %> has no default value (and none provided).
      END
    end
  end
  
  
  # Does this property have a source method that it gets it's value from?
  # 
  # @return [Boolean]
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
  
  
  # Get the value of the prop from an instance.
  # 
  # @note
  #   At the moment, values are **not** type-checked when reading. Primary
  #   values are checked when setting, so they should be ok, but this does
  #   leave the possibility that props with a {#source} may return values
  #   that do not satisfy their types... :/
  # 
  # @param [NRSER::Props] instance
  #   An instance of {#defined_in}.
  # 
  # @return
  #   Value from the instance's prop value storage (for {#primary?} props)
  #   or it's {#source}.
  # 
  def get instance
    if source?
      if instance_variable_source?
        instance.instance_variable_get source
      else
        t.match source,
          t.or( String, Symbol ),
            ->( name ) { instance.send name },
          Proc,
            ->( block ) { instance.instance_exec &block }
      end
    else
      # Go through the storage engine
      instance.class.metadata.storage.get instance, self
    end
  end # #get
  
  
  # Set a value for a the prop on an instance.
  # 
  # @param [NRSER::Props] instance
  #   An instance of {#defined_in}.
  # 
  # @param [*] value
  #   A value that must satisfy {#type}.
  # 
  # @return [nil]
  # 
  # @raise [RuntimeError]
  #   If you try to set a value for a prop that isn't {#primary?}.
  # 
  # @raise  (see #check!)
  # 
  def set instance, value
    unless primary?
      raise RuntimeError.new binding.erb <<~END
        Only {#primary?} props can be set!
        
        Tried to set prop #{ prop.name } to value
        
            <%= value.pretty_inspect %>
        
        in instance
        
            <%= instance.pretty_inspect %>
        
      END
    end
    
    instance.class.metadata.storage.put \
      instance,
      self,
      check!( value )
    
    nil
  end # #set
  
  
  # Check that a value satisfies the {#type}, raising if it doesn't.
  # 
  # @param [VALUE] value
  #   Value to check.
  # 
  # @return [VALUE]
  #   `value` arg that was passed in.
  # 
  # @raise [NRSER::Types::CheckError]
  #   If `value` does not satisfy {#type}.
  # 
  def check! value
    type.check!( value ) do
      binding.erb <<-END
        Value of type <%= value.class.safe_name %> for prop <%= self.full_name %>
        failed type check.
        
        Must satisfy type:
        
            <%= type %>
        
        Given value:
        
            <%= value.pretty_inspect %>
        
      END
    end
  end # #check!
  
  
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
  # @param [NRSER::Props::Props] instance
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
  
  
  # Load a value for the prop from "data".
  # 
  # @param [*] data
  # 
  # @return [VALUE]
  #   The prop value to use.
  # 
  def value_from_data data
    value = case @from_data
    when nil
      # This {Prop} does not have any custom `from_data` instructions, which
      # means we must rely on the {#type} to covert *data* to a *value*.
      # 
      if data.is_a?( String ) && type.has_from_s?
        type.from_s data
      elsif type.has_from_data?
        type.from_data data
      else
        data
      end
      
    when Symbol, String
      # The custom `from_data` configuration specifies a string or symbol name,
      # which we interpret as a class method on the defining class and call
      # with the data to produce a value.
      @defined_in.send @from_data, data
    
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
  
  
  def to_desc
    "#{ full_name }:#{ type }"
  end
  
  
  # @return [String]
  #   a short string describing the instance.
  # 
  def to_s
    "#<#{ self.class.safe_name } #{ to_desc }>"
  end # #to_s
  
end # class Prop


# /Namespace
# =======================================================================

end # module Props
end # module NRSER
