require 'nrser/refinements'
require 'nrser/types/is'
require 'nrser/types/is_a'
require 'nrser/types/attrs'

using NRSER
  
module NRSER::Types
  def self.str length: nil, **options
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
  
  singleton_class.send :alias_method, :string, :str
  
  STR = str( name: 'StringType' ).freeze
  
  EMPTY_STR = str( name: 'EmptyStringType', length: 0 ).freeze
  
  def self.empty_str
    EMPTY_STR
  end
  
  def self.non_empty_str **options
    return NON_EMPTY_STR if options.empty?
    
    str( length: {min: 1}, **options )
  end # .non_empty_str
  
  NON_EMPTY_STR = non_empty_str( name: 'NonEmptyStr' ).freeze
  
end # NRSER::Types