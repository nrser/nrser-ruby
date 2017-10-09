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
  
  
  SYM = sym name: 'SymType'
  
end # NRSER::Types