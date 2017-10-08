require 'spec_helper'


# NRSER::Types.hash_pair
# ========================================================================
# 
describe "NRSER::Types.hash_pair" do
  subject { NRSER::Types.method :hash_pair }
  
  it_behaves_like 'Type maker method',
    accepts: [
      {x: 1},
    ],
    
    rejects: [
      {x: 1, y: 2},
    ]
  
end # NRSER::Types.hash_pair

# ************************************************************************

