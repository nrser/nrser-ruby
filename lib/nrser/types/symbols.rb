require 'nrser/refinements'
require 'nrser/types/is'
require 'nrser/types/is_a'

require 'nrser/refinements'
using NRSER
  
module NRSER::Types

  def self.sym **options
    IsA.new(
      Symbol,
      from_s: :to_sym.to_proc,
      **options
    )
  end # sym
  
  singleton_class.send :alias_method, :symbol, :sym
  
  
  def self.empty_sym **options
    is :'', name: 'EmptySymbol', **options
  end
  
  
  def self.non_empty_sym **options
    intersection \
      sym,
      self.not( empty_sym ),
      name: 'NonEmptySymbol',
      **options
  end
  
end # NRSER::Types
