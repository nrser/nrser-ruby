require 'nrser/refinements'
require 'nrser/types/is'
require 'nrser/types/is_a'

require 'nrser/refinements'
using NRSER
  
module NRSER::Types

  def self.sym **options
    if options.empty?
      # if there are no options can point to the constant for efficiency
      SYM
    else
      IsA.new(
        Symbol,
        from_s: :to_sym.to_proc,
        **options
      )
    end
  end # sym
  
  singleton_class.send :alias_method, :symbol, :sym
  
  SYM = sym( name: 'SymType' ).freeze
  
  
  def self.non_empty_sym **options
    return NON_EMPTY_SYM if options.empty?
    
    intersection \
      SYM,
      attrs( {to_s: non_empty_str} ),
      **options
  end
  
  NON_EMPTY_SYM = non_empty_sym( name: 'NonEmptySym' ).freeze
  
end # NRSER::Types