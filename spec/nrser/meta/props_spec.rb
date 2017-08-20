require 'spec_helper'

using NRSER::Types

describe NRSER::Meta::Props do
  
  # Setup
  # =====================================================================
  
  let(:point) {
    Class.new(NRSER::Meta::Props::Base) do
      # include NRSER::Meta::Props
      
      prop :x, type: t.int
      prop :y, type: t.int
      prop :blah, type: t.str, source: :blah
      
      def blah
        "blah!"
      end
    end
  }
  
  it "has the props" do
    props = point.props
    
    expect(props).to be_a Hash
    
    [:x, :y, :blah].each do |name|
      expect(props[name]).to be_a NRSER::Meta::Props::Prop
    end
    
    [:x, :y].each do |name|
      expect(props[name].source?).to be false
      expect(props[name].primary?).to be true
    end
    
    expect(props[:blah].source?).to be true
    expect(props[:blah].primary?).to be false
    
    primary_props = point.props only_primary: true
    
    expect(primary_props.key? :blah).to be false
    
    p = point.new x: 1, y: 2
    
    expect(p.x).to be 1
    expect(p.y).to be 2
    
    expect(p.to_h).to eq({x: 1, y: 2, blah: "blah!"})
    expect(p.to_h(only_primary: true)).to eq({x: 1, y: 2})
    
    expect { point.new x: 1, y: 'why?' }.to raise_error TypeError
    expect { p.x = 3 }.to raise_error NoMethodError
    
    p_hash = p.to_h
    
    p2 = point.new p_hash
    
    expect(p2.x).to be 1
    expect(p2.y).to be 2
    
    expect(p2.to_h).to eq({x: 1, y: 2, blah: "blah!"})
  end
  
end # NRSER::Meta::Props

