require 'nrser/refinements/types'
using NRSER::Types


# NRSER::Types.tuple
# ========================================================================
# 
describe "NRSER::Types.tuple" do
  subject { NRSER::Types.method :tuple }
  
  it_behaves_like 'type maker method'
  
  include_examples 'make type',
    args: [],
    accepts: [ [] ],
    rejects: [ [1] ]
    
  include_examples 'make type',
    args: [t.int, t.int],
    accepts: [ [1, 2] ],
    rejects: [ [1, :x], [1], [1, 2, 3] ],
    from_s: {
      accepts: {
        '1, 2' => [1, 2],
        '[1, 2]' => [1, 2],
      },
      rejects: {},
    }
  
end # NRSER::Types.tuple

# ************************************************************************
