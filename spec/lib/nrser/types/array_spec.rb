# encoding: UTF-8
# frozen_string_literal: true

require 'nrser/refinements/types'
using NRSER::Types


# NRSER::Types.array
# ========================================================================
# 
SPEC_FILE(
  spec_path: __FILE__,
  module: NRSER::Types,
  method: :array,
) do
  
  it_behaves_like 'type maker method'
  
  include_examples 'make type',
    accepts: [
      [],
      [1, 2, 3],
      [:a, 2, 'c']
    ],
    
    rejects: [
      nil,
      {},
      '1,2,3',
    ],
    
    from_s: {
      accepts: {
        # String splitting with default splitter
        '1,2,3' => ['1', '2', '3'],
        '1, 2,   3' => ['1', '2', '3'],
        "1,\n2,\n3" => ['1', '2', '3'],
        
        # JSON encoded
        JSON.dump([1, 2, 3]) => [1, 2, 3],
        
        JSON.pretty_generate([
          {x: 'ex!'},
          {y: 'why?'}
        ]) => [{'x' => 'ex!'}, {'y' => 'why?'}],
      },
    },
    
    and_is_expected: {
      to: {
        have_attributes: {
          class: t::ArrayType,
          name: 'Array',
        }
      }
    }
  
  include_examples 'make type',
    args: [t.int],
    
    accepts: [
      [],
      [1, 2, -3, 0],
    ],
    
    rejects: [
      [1, 2, :c],
    ],
    
    from_s: {
      accepts: {
        '1, 2, 3' => [1, 2, 3],
      },
      
      rejects: {
        'a, b, c' => ArgumentError,
      }
    }
  
end # NRSER::Types.array

# ************************************************************************
