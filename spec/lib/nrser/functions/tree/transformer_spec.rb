# Examples
# =====================================================================

METHOD "NRSER.transformer" do
# ========================================================================
# 
# Basically the same {NRSER.transform} tests but using {NRSER.transformer}
# to build the trees instead of {#sender}, {#chainer}, etc.
# 
  
  CASE "Simple Examples" do
  # ========================================================================
  
    subject { NRSER.transform tree, source }
    
    describe "value swap in {x: 'ex', y: 'why?'}" do
      
      let( :tree ) {
        NRSER.transformer do |h|
          {
            x: h[:y],
            y: h[:x],
          }
        end
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
        NRSER.transformer do |contact|
          {
            users: {
              { id: contact[:id] } => {
                name: contact[:name],
              }
            }
          }
        end
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
    
    
    describe "arrays in tree" do
      let :tree do
        NRSER.transformer do |h|
          {
            list: [
              { name: h[:name] },
              { age: h[:age] },
            ]
          }
        end
      end
      
      let :source do
        {
          name: 'Mr. Cat',
          age: 2,
        }
      end
      
      it do
        is_expected.to eq \
          list: [
            { name: 'Mr. Cat' },
            { age: 2 },
          ]
      end
    end # arrays in tree
    
    
  end # CASE simple examples
  # ************************************************************************
  
  
  CASE "Real-World Examples" do
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
    
  end # CASE Real-World Examples
  # ************************************************************************
  
  
end # NRSER.transform
