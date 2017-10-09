require 'spec_helper'

require 'nrser/refinements'
using NRSER

require 'nrser/refinements/types'
using NRSER::Types


# NRSER::Types.str
# ========================================================================
# 
describe "NRSER::Types.str" do
  subject { NRSER::Types.method :str }
  
  it_behaves_like 'type maker method'
  
  include_examples 'make type',
    accepts: [ 'hey', '' ],
    rejects: [ 1, {}, nil, ],
    from_s: {
      accepts: {
        'hey' => 'hey',
        '' => '',
      }
    }
    
  include_examples 'make type',
    args: [length: 0],
    accepts: [ '', ],
    rejects: [ 'hey', ]

  include_examples 'make type',
    args: [length: 3],
    accepts: [ 'hey', 'hoe' ],
    rejects: [ 'he', 'ha' ]
  
end # NRSER::Types.str

# ************************************************************************


# NRSER::Types.non_empty_str
# ========================================================================
# 
describe "NRSER::Types.non_empty_str" do
  subject { NRSER::Types.method :non_empty_str }
  
  it_behaves_like 'type maker method'
  
  include_examples 'make type',
    args: [],
    accepts: [ 'hey', 'ho', "let's go" ],
    rejects: [ '', nil, 1 ],
    from_s: {
      accepts: {
        
      },
      rejects: {
        
      }
    }
  
end # NRSER::Types.non_empty_str

# ************************************************************************
