require_relative './is'
require_relative './is_a'
require_relative './attributes'
require_relative './not'

  
module NRSER::Types
  
  # @!group Type Factory Functions
  
  def_factory(
    :String,
    aliases: [ :str, :string ],
  ) do |length: nil, encoding: nil, **options|
    if [length, encoding].all?( &:nil? )
      IsA.new ::String, from_s: ->(s) { s }, **options
      
    else
      types = [str]
      types << self.length( length ) if length
      types << attrs( encoding: encoding ) if encoding
      
      intersection *types, **options
    end
  end # String
  
  
  # Get a {Type} only satisfied by empty strings.
  # 
  # @param [String] name (default 'EmptyString')
  # 
 def_factory(
   :EmptyString,
   aliases: [ :empty_str, :empty_string ],
  ) do |name: 'EmptyString', **options|
    str length: 0, name: name, **options
  end
  
  
 def_factory(
   :NonEmptyString,
   aliases: [ :non_empty_str, :non_empty_string ],
  ) do |name: 'NonEmptyString', **options|
    str length: {min: 1}, name: name, **options
  end
  
  
 def_factory(
   :Character,
   aliases: [ :char, :character ],
  ) do |name: 'Character', **options|
    str length: 1, name: name, **options
  end
  
  
  # A type satisfied by UTF-8 encoded strings.
  # 
  # @param [String] name (default 'UTF8String')
  # 
  def_factory :uft_8, aliases: [:utf8] do |name: 'UTF8String', **options|
    str encoding: Encoding::UTF_8, name: name, **options
  end
  
  
  def_factory(
    :utf_8_char,
    aliases: [:utf8_char]
  ) do |name: 'UTF8Character', **options|
    str length: 1, encoding: Encoding::UTF_8, name: name, **options
  end
  
end # NRSER::Types
