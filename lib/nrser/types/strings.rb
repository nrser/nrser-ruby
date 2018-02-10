require 'nrser/refinements'
require 'nrser/types/is'
require 'nrser/types/is_a'
require 'nrser/types/attrs'
require 'nrser/types/not'

using NRSER
  
module NRSER::Types
  
  # @!group Type Factory Functions
  
  def self.str length: nil, encoding: nil, **options
    if [length, encoding].all?( &:nil? )
      IsA.new String, from_s: ->(s) { s }, **options
      
    else
      types = [str]
      types << self.length( length ) if length
      types << attrs( encoding: encoding ) if encoding
      
      intersection *types, **options
    end
  end # string
  
  singleton_class.send :alias_method, :string, :str
  
  
  # Get a {Type} only satisfied by empty strings.
  # 
  # @param [String] name: (default 'EmptyString')
  # 
  factory :empty_str do |name: 'EmptyString', **options|
    str length: 0, name: name, **options
  end
  
  
  factory :non_empty_str do |**options|
    str length: {min: 1}, **options
  end
  
  
  factory :char do |**options|
    str length: 1, name: "Character", **options
  end
  
  
  # A type satisfied by UTF-8 encoded strings.
  # 
  # @param [String] name: (default 'UTF8String')
  # 
  factory :uft_8, aliases: [:utf8] do |name: 'UTF8String', **options|
    str encoding: Encoding::UTF_8, name: name, **options
  end
  
end # NRSER::Types
