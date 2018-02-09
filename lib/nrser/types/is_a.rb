require 'nrser/refinements'
require 'nrser/types/type'
using NRSER

module NRSER::Types
  class IsA < NRSER::Types::Type
    attr_reader :klass
    
    def initialize klass, **options
      unless klass.is_a?( Class ) || klass.is_a?( Module )
        raise ArgumentError.new binding.erb <<-ERB
          `klass` argument must be a Class or Module, found:
          
              <%= klass.pretty_inspect %>
          
        ERB
      end
      
      super **options
      @klass = klass
    end
    
    
    def default_name
      @klass.name
    end
    
    
    def test value
      value.is_a? @klass
    end
    
    
    # If {#klass} responds to `#from_data`, call that and check results.
    # 
    # Otherwise, forward up to {NRSER::Types::Type#from_data}.
    # 
    # @param [Object] data
    #   Data to create the value from that will satisfy the type.
    # 
    # @return [Object]
    #   Instance of {#klass}.
    # 
    def from_data data
      if @from_data.nil?
        if @klass.respond_to? :from_data
          check @klass.from_data( data )
        else
          super data
        end
      else
        @from_data.call data
      end
    end
    
    
    def has_from_data?
      @from_data || @klass.respond_to?( :from_data )
    end
    
    
    def == other
      equal?( other ) ||
      ( self.class == other.class &&
        self.klass == other.klass )
    end
    
  end # IsA
  
  
  # class membership
  def self.is_a klass, **options
    IsA.new klass, **options
  end
end # NRSER::Types
