require 'spec_helper'

describe NRSER.method(:to_open_struct) do
  
  context "shallow Hash" do
    let(:hash) { {a: 1, b: 2} }
    let(:result) { subject.call hash }
    
    it "is converted to an OpenStruct" do
      expect(result).to be_a OpenStruct
      expect(result.a).to be hash[:a]
      expect(result.b).to be hash[:b]
    end # converts to an OpenStruct
  end # Shallow Hash
  
  context "deep Hash" do
    let(:hash) {
      {
        a: {
          x: 'ex',
          y: 'why',
        },
        
        b: [
          {z: 'zee!'},
          3,
          {'w' => nil},
        ],
      }
    }
    
    let(:result) { subject.call hash }
    
    it "is deeply converted into OpenStruct instances" do
      expect(result).to be_a OpenStruct
      expect(result.a).to be_a OpenStruct
      expect(result.b[2]).to be_a OpenStruct
      expect(result.a.x).to eq 'ex'
      expect(result.b[0].z).to eq 'zee!'
    end # is deeply converted into OpenStruct instances
    
  end # Deep hash
  
  
  context "not a Hash" do
    it "raises NoMethodError" do
      expect { subject.call 1 }.to raise_error TypeError
      expect { subject.call [1, 2, 3] }.to raise_error TypeError
    end
  end # not a Hash
  
end # NRSER.to_open_struct
