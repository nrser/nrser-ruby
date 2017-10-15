require 'spec_helper'

require 'nrser/refinements'
using NRSER


# NRSER.merge_by
# ========================================================================
# 
describe "NRSER.merge_by" do
  subject { NRSER.method :merge_by }
  
  context "line items example" do
    let( :current ) {
      [
        {
          line_item_id: 123,
          item_id: 1,
          quantity: 1,
        },
        
        {
          line_item_id: 456,
          item_id: 2,
          quantity: 4,
        },
      ]
    }
    
    let( :update ) {
      [
        {
          item_id: 1,
          quantity: 4,
        },
        
        {
          item_id: 3,
          quantity: 1,
        }
      ]
    }
    
    subject {
      super().call current, update, &[:item_id].digger
    }
    
    it {
      is_expected.to include(
        {
          line_item_id: 123,
          item_id: 1,
          quantity: 4,
        },
        
        {
          line_item_id: 456,
          item_id: 2,
          quantity: 4,
        },
        
        {
          item_id: 3,
          quantity: 1,
        }
      )
    }
    
  end # line items example
  
end # NRSER.merge_by

# ************************************************************************
