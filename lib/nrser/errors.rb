
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
require_relative './errors/argument_error'
require_relative './errors/type_error'
require_relative './errors/abstract_method_error'
require_relative './errors/conflict_error'
require_relative './errors/unreachable_error'


module NRSER
  
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
      
      message = binding.erb <<-END
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
