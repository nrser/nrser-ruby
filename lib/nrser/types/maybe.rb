require_relative './combinators'
require_relative './nil'

module NRSER::Types
    
  # Type satisfied by `nil` or the parametrized type.
  # 
  def_factory(
    :maybe,
  ) do |type, **options|
    union \
      self.nil,
      type,
      name: (options[:name] || "#{ type.name }?"),
      **options
  end
  
end # NRSER::Types
