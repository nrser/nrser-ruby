require 'nrser/refinements'
require 'nrser/types/is'
require 'nrser/types/is_a'
require 'nrser/types/attrs'

using NRSER
  
module NRSER::Types
  STR = IsA.new String, name: 'Str', from_s: ->(s) { s }
  
  def self.str **options
    if options.empty?
      # if there are no options can point to the constant for efficiency
      STR
    else
      types = []
      
      if options[:length]
        types << length(options[:length])
      end
      
      intersection STR, *types
    end
  end # string
  
  def self.string
    str
  end
  
  EMPTY_STR = Is.new ''
  
  NON_EMPTY_STR = str length: {min: 1}, name: "NonEmptyStr"
  
  
  def self.non_empty_str
    NON_EMPTY_STR
  end # .non_empty_str
  
  
end # NRSER::Types