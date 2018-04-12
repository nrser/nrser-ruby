require 'nrser/refinements'
require 'nrser/types/type'
using NRSER

module NRSER::Types
  # Type satisfied by class membership (or mixin presence for modules).
  # 
  # Tests via the subject value's `#is_a?` method.
  # 
  class IsA < NRSER::Types::Type
    attr_reader :mod
    
    def initialize mod, init_from_data: false, **options
      unless mod.is_a?( Module )
        raise ArgumentError,
          "`mod` argument must be a Module (inc. Class), " \
          "received #{ mod.inspect }"
      end
      
      super **options
      
      @init_from_data = !!init_from_data
      
      @mod = mod
    end
    
    
    def explain
      mod.safe_name
    end
    
    
    def test? value
      value.is_a? mod
    end
    
    
    
    # @todo Document init_from_data? method.
    # 
    # @param [type] arg_name
    #   @todo Add name param description.
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def init_from_data?
      @init_from_data
    end # #init_from_data?
    
    
    
    # Forwards to `mod.from_data`.
    # 
    # @param data (see NRSER::Types::Type#from_data)
    # @return     (see NRSER::Types::Type#from_data)
    # @raise      (see NRSER::Types::Type#from_data)
    # 
    def custom_from_data data
      if init_from_data?
        mod.new data
      else
        mod.from_data data
      end
    end
    
    
    # Overrides {NRSER::Types::Type#has_from_data?} to respond `true` when
    # there is a instance-specific `@from_data` or the {#mod} responds to
    # `.from_data`.
    # 
    # @return [Boolean]
    # 
    def has_from_data?
      @from_data ||
        init_from_data? ||
        mod.respond_to?( :from_data )
    end
    
    
    def == other
      equal?( other ) ||
      ( self.class == other.class &&
        self.mod == other.mod )
    end
    
  end # IsA
  
  
  # class membership
  def_factory :is_a do |mod, **options|
    IsA.new mod, **options
  end
end # NRSER::Types
