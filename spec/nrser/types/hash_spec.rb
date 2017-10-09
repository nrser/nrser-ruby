require 'spec_helper'


# NRSER::Types.hash_pair
# ========================================================================
# 
describe "NRSER::Types.hash_pair" do
  subject { NRSER::Types.method :hash_pair }
  
  include_examples 'make type',
    accepts: [
      {x: 1},
    ],
    
    rejects: [
      {x: 1, y: 2},
    ]
  
end # NRSER::Types.hash_pair

# ************************************************************************

