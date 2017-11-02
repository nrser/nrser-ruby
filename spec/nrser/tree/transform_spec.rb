require 'spec_helper'

require 'nrser/refinements'
using NRSER

describe "NRSER.transform" do
  subject { NRSER.transform tree, source }
  
  describe_section "Simple Examples" do
  # ========================================================================
    
    describe "value swap in {x: 'ex', y: 'why?'}" do
      
      let( :tree ) {
        {
          x: :y.to_getter,
          y: :x.to_getter,
        }
      } # let :tree
      
      let( :source ) {
        {
          x: 'ex',
          y: 'why?'
        }
      } # let :source
      
      it { is_expected.to eq x: 'why?', y: 'ex' }
      
    end # value swap in {x: 'ex', y: 'why?'}
    
    
    describe "transform in key" do
      
      let :tree do
        {
          users: {
            { id: :id.to_getter } => {
              name: :name.to_getter,
            }
          }
        }
      end
      
      let :source do
        {
          id: 123,
          name: "Mr. Cat",
        }
      end
      
      it do
        is_expected.to eq \
          users: {
            { id: 123 } => {
              name: "Mr. Cat",
            }
          }
      end
      
    end # transform in key
    
  end # section simple examples
  # ************************************************************************
  
  
  describe_section "Real-World Examples" do
  # ========================================================================
    
    describe "Address" do
      
      let :contact do
        OpenStruct.new id: 123
      end
      
      let :address do
        OpenStruct.new \
          id:         987,
          parent:     contact,
          address:    "东城区",
          street2:    "民安小区",
          city:       "北京市",
          state:      "北京",
          zip:        "100010"
      end
      
      let :source do
        address
      end
      
      let :tree do
        {
          users: {
            { contact_id: [ :parent, :id ].to_digger } => {
              addresses: {
                { 
                  address_id: [ :id ].to_sender } => {
                  district:   :address.to_getter,
                  line_1:     :street2.to_getter,
                  city:       :city.to_getter,
                  province:   :state.to_getter,
                  post_code:  :zip.to_getter,
                }
              }
            }
          }
        }
      end
      
      it do
        is_expected.to eq \
          users: {
            { contact_id: 123 } => {
              addresses: {
                { address_id: 987 } => {
                  district:   "东城区",
                  line_1:     "民安小区",
                  city:       "北京市",
                  province:   "北京",
                  post_code:  "100010",
                }
              }
            }
          }
      end
      
    end # Address
    
  end # section Real-World Examples
  # ************************************************************************
  
  
end # NRSER.transform
