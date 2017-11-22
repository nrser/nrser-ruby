require 'nrser/refinements'
require 'nrser/types/is'
require 'nrser/types/is_a'
require 'nrser/types/attrs'

using NRSER
  
module NRSER::Types
  
  # Eigenclass (Singleton Class)
  # ========================================================================
  # 
  class << self
    # @!group Type Factory Functions
    
    def str length: nil, **options
      if length.nil? && options.empty?
        # if there are no options can point to the constant for efficiency
        STR
      else
        if length.nil?
          IsA.new String, from_s: ->(s) { s }, **options
        else
          intersection \
            IsA.new( String, from_s: ->(s) { s } ),
            NRSER::Types.length( length ),
            **options
        end
      end
    end # string
    
    alias_method :string, :str
    
    
    def empty_str
      EMPTY_STR
    end
    
    
    def non_empty_str **options
      return NON_EMPTY_STR if options.empty?
      
      str( length: {min: 1}, **options )
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
  
  EMPTY_STR = str( name: 'EmptyStringType', length: 0 ).freeze
  
  NON_EMPTY_STR = non_empty_str( name: 'NonEmptyStr' ).freeze
  
end # NRSER::Types