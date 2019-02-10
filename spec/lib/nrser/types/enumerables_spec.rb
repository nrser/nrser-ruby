# encoding: UTF-8
# frozen_string_literal: true

require 'nrser/refinements/types'
using NRSER::Types


SPEC_FILE(
  spec_path: __FILE__,
  module: NRSER::Types,
  method: :Enumerable,
) do
  
  it_behaves_like 'type maker method'
  
  include_examples 'make type',
    args: [ Array, Integer  ],

    accepts: [
      [],
      [1, 2, 3],
    ],

    rejects: [
      nil,
      {},
      Set[1, 2, 3],
    ],
    
    block: -> {
      it {
        is_expected.
          to have_attributes class: t::EnumerableType, name: 'Array<Integer>'
      }
    }
  
end # SPEC_FILE