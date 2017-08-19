require 'nrser/refinements'
require 'nrser/types/is'
require 'nrser/types/is_a'

using NRSER
  
module NRSER::Types
  SYM = IsA.new Symbol, name: 'Sym', from_s: ->(s) { s.to_sym }
  
  def self.sym **options
    if options.empty?
      # if there are no options can point to the constant for efficiency
      SYM
    else
      raise "Not Implemented"
    end
  end # string
  
  def self.symbol *args
    sym *args
  end
  
end # NRSER::Types