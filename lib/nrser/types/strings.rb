require 'nrser/refinements'
require 'nrser/types/is'
require 'nrser/types/is_a'
require 'nrser/types/attrs'
require 'nrser/types/not'

using NRSER
  
module NRSER::Types
  
  # Eigenclass (Singleton Class)
  # ========================================================================
  # 
  class << self
    # @!group Type Factory Functions
    
    def str length: nil, **options
      if length.nil?
        IsA.new String, from_s: ->(s) { s }, **options
      else
        intersection \
          IsA.new( String, from_s: ->(s) { s } ),
          NRSER::Types.length( length ),
          **options
      end
    end # string
    
    alias_method :string, :str
    
    
    def empty_str **options
      str length: 0, name: 'EmptyString', **options
    end
    
    
    def non_empty_str **options
      str length: {min: 1}, **options
    end # .non_empty_str
    
    
    private
    # ========================================================================
      
      
      # @todo Document make_string_type method.
      # 
      # @param [type] arg_name
      #   @todo Add name param description.
      # 
      # @return [return_type]
      #   @todo Document return value.
      # 
      def make_string_type length: nil, match: nil
        # method body...
      end # #make_string_type
      
      
    # end private
    
  end # class << self (Eigenclass)
  
  STR = str( name: 'StringType' ).freeze
  
end # NRSER::Types
