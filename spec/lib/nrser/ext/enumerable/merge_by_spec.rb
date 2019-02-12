require 'nrser/ext/enumerable/merge_by'

SPEC_FILE(
  spec_path: __FILE__,
  module: NRSER::Ext::Enumerable,
  instance_method: :merge_by,
) do
    
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
    
    subject { current.n_x.merge_by( update ) { |a| a[ :item_id ] } }
    
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
  
end # SPEC_FILE

# ************************************************************************
