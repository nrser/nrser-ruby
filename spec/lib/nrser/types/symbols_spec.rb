require 'spec_helper'

require 'nrser/refinements'
using NRSER

require 'nrser/refinements/types'
using NRSER::Types


# NRSER::Types.non_empty_sym
# ========================================================================
# 
describe "NRSER::Types.non_empty_sym" do
  subject { NRSER::Types.method :non_empty_sym }
  
  it_behaves_like 'type maker method'
  
  include_examples 'make type',
    args: [],
    accepts: [ :x, :y ],
    rejects: [ :'', nil, 'x', 1 ],
    from_s: {
      accepts: {
        
      },
      rejects: {
        
      }
    },
    and_is_expected: {
      to: {
        have_attributes: {
          name: 'NonEmptySymbol'
        }
      }
    }
  
end # NRSER::Types.non_empty_sym
