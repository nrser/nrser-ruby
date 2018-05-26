require 'nrser/refinements/types'
using NRSER::Types


# NRSER::Types.hash_pair
# ========================================================================
# 
describe "NRSER::Types.hash_pair" do
  subject { NRSER::Types.method :hash_pair }
  
  it_behaves_like 'type maker method'
  
  include_examples 'make type',
    accepts: [
      {x: 1},
    ],
    
    rejects: [
      {x: 1, y: 2},
    ]
  
  include_examples 'make type',
    args: [key: t.label, value: t.int],
    
    accepts: [
      {x: 1},
    ],
    
    rejects: [
      {x: :y},
    ]
  
end # NRSER::Types.hash_pair

# ************************************************************************
