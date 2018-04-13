require_relative './combinators'
require_relative './strings'

# Definitions
# =======================================================================

module NRSER::Types
  
  # A label is a non-empty {String} or {Symbol}.
  # 
  # @param [Hash] **options
  #   Options to pass to {NRSER::Types::Type#initialize}.
  # 
  # @return [NRSER::Types::Type]
  # 
  def_factory(
    :label,
  ) do |name: 'Label', **options|
    union non_empty_str, non_empty_sym, **options
  end # .label
  
end # module NRSER::Types
