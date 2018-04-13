require_relative './is'
  
module NRSER::Types
  # Type for `nil`, itself and only.
  # 
  # @todo
  #   Should we have a `#from_s` that converts the empty string to `nil`?
  #   
  #   Kind-of seems like we would want that to be a different types so that
  #   you can have a Nil type that is distinct from the empty string in
  #   parsing, but also have a type that accepts the empty string and coverts
  #   it to `nil`?
  #   
  #   Something like:
  #   
  #       type = t.empty | t.non_empty_str
  #       type.from_s ''
  #       # => nil
  #       type.from_s 'blah'
  #       # => 'blah'
  # 
  def_factory(
    :nil,
    aliases: [ :null ],
  ) do |name: 'Nil', **options|
    is nil, name: name, **options
  end
end # NRSER::Types
