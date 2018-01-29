
# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------
require_relative './errors/value_error'
require_relative './errors/attr_error'
require_relative './errors/count_error'


module NRSER
  
  # Indicates some piece of application state is in conflict with the attempted
  # operation.
  class ConflictError < StandardError; end
  
  
  # Extension of Ruby's {NotImplementedError} to provide a useful message
  # and convenient constructor for abstract methods.
  # 
  # @example
  #   
  #   def f
  #     raise NRSER::AbstractMethodError.new( self, __method__ )
  # 
  # 
  class AbstractMethodError < NotImplementedError
    
    # Construct a new `AbstractMethodError`.
    # 
    # @param [Object] instance
    #   Instance that invoked the abstract method.
    # 
    # @param [Symbol | String] method_name
    #   Name of abstract method.
    # 
    def initialize instance, method_name
      @instance = instance
      @method_name = method_name
      @method = instance.method @method_name
      
      message = if @method.owner == instance.class
        NRSER.dedent <<-END
          Method #{ @method.owner.name }##{ @method_name } is abstract, meaning
          #{ @method.owner.name } is an abstract class and the invoking
          instance #{ @instance } should NOT have been constructed.
        END
      else
        NRSER.squish <<-END
          Method #{ @method.owner.name }##{ @method_name } is abstract and
          has not been implemented in invoking class #{ @instance.class }.
          
          If you *are* developing the invoking class #{ @instance.class } it
          (or a parent class between it and #{ @method.owner.name }) must
          implement ##{ @method_name }.
          
          If you *are not* developing #{ @instance.class } it should be treated
          as an abstract base class and should NOT be constructed. You need to
          find a subclass of #{ @instance.class } to instantiate or write
          your own.
        END
      end
      
      super message
    end # #initialize
    
  end # class AbstractMethodError
  
  
  # A wrapper error around a list of other errors.
  # 
  class MultipleErrors < StandardError
    
    # Attributes
    # ======================================================================
    
    # The individual errors that occurred.
    # 
    # @return [Array<Exception>]
    #     
    attr_reader :errors
    
    
    # Constructor
    # ======================================================================
    
    # Instantiate a new `MultipleErrors`.
    def initialize errors, headline: nil
      @errors = errors
      
      if headline.nil?
        class_counts = NRSER.count_by( errors, &:class ).
          map { |klass, count| "#{ klass } (#{ count })" }.
          join( ', ' )
        
        headline = "#{ errors.count } error(s) occurred - #{ class_counts }"
      end
      
      message = NRSER.erb binding, <<-END
        <%= headline %>
        
        <% errors.each_with_index do |error, index| %>
        <%= (index.succ.to_s + ".").ljust( 3 ) %> <%= error.message %> (<%= error.class %>):
            <%= error.backtrace.join( $/ ) %>
        <% end %>
        
      END
      
      super message
    end # #initialize
    
    
  end # class MultipleErrors
  

end # module NRSER
