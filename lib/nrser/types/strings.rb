require 'nrser/refinements'
require 'nrser/types/is'
require 'nrser/types/is_a'
require 'nrser/types/attrs'

using NRSER
  
module NRSER::Types
  STR = IsA.new String, name: 'Str', from_s: ->(s) { s }
  
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
  
  STR = str( name: 'StrType' ).freeze
  
  EMPTY_STR = Is.new( '' ).freeze
  
  NON_EMPTY_STR = str( length: {min: 1}, name: "NonEmptyStr" ).freeze
  
  def self.non_empty_str
    NON_EMPTY_STR
  end # .non_empty_str
  
  
end # NRSER::Types