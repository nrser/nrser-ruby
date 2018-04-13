require_relative './is'
require_relative './is_a'

module NRSER::Types

  def_factory(
    :Symbol,
    aliases: [ :sym, :symbol ],
  ) do |from_s: :to_sym.to_proc, **options|
    is_a \
      ::Symbol,
      from_s: from_s,
      **options
  end # sym
  
  
  def_factory(
    :EmptySymbol,
    aliases: [ :empty_sym, :empty_symbol ],
  ) do |name: 'EmptySymbol', **options|
    is :'', name: name, **options
  end
  
  
  def_factory(
    :NonEmptySymbol,
    aliases: [ :non_empty_sym, :non_empty_symbol ],
  ) do |name: 'NonEmptySymbol', **options|
    intersection \
      sym,
      self.not( empty_sym ),
      name: name,
      **options
  end
  
end # NRSER::Types
