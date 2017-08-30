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
    
    context "freeze: true" do
      subject { super().call hash, freeze: true }
      
      it "is converted to an OpenStruct" do
        expect(subject).to be_a OpenStruct
        expect(subject.a).to be hash[:a]
        expect(subject.b).to be hash[:b]
      end # converts to an OpenStruct
      
      it "is frozen" do
        expect(subject.frozen?).to be true
      end # is frozen
      
    end # freeze: true
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
    
    
    context "freeze: true" do
      
      subject { super().call hash, freeze: true }
      
      it "is deeply converted into OpenStruct instances" do
        expect(subject).to be_a OpenStruct
        expect(subject.a).to be_a OpenStruct
        expect(subject.b[2]).to be_a OpenStruct
        expect(subject.a.x).to eq 'ex'
        expect(subject.b[0].z).to eq 'zee!'
      end # is deeply converted into OpenStruct instances
      
      it "is frozen" do
        expect(subject.frozen?).to be true
        expect(subject.a.frozen?).to be true
      end # is frozen
      
      it "can't be modified" do
        expect { subject.a = 3 }.to raise_error RuntimeError
        expect { subject.q = 3 }.to raise_error RuntimeError
        expect { subject.b[0].z = 3 }.to raise_error RuntimeError
      end # can't be modified
      
      
    end # freeze: true
    
  end # Deep hash
  
  
  context "not a Hash" do
    it "raises NoMethodError" do
      expect { subject.call 1 }.to raise_error TypeError
      expect { subject.call [1, 2, 3] }.to raise_error TypeError
    end
  end # not a Hash
  
end # NRSER.to_open_struct
