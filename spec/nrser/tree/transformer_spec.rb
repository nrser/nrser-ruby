require 'spec_helper'

require 'nrser/refinements'
using NRSER

describe "NRSER.transformer" do
  # subject { NRSER.method :transformer }
  
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
        NRSER.transformer do |address|
          {
            users: {
              { contact_id: address.parent.id } => {
                addresses: {
                  { 
                    address_id: address.id } => {
                    district:   address[:address],
                    line_1:     address[:street2],
                    city:       address[:city],
                    province:   address[:state],
                    post_code:  address[:zip],
                  }
                }
              }
            }
          }
        end
      end
      
      subject { NRSER.transform tree, address }
      
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

