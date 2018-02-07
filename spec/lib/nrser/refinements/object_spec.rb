require 'spec_helper'

using NRSER

describe "Refinements for Object" do
  
  describe '#as_hash' do
    context "self is a Hash" do
      it "returns self" do
        h = {a: 1}
        expect(h.as_hash).to be h
        # key doesn't matter
        expect(h.as_hash(:x)).to be h
      end # returns itself when self is a hash
    end # self is a Hash
    
    context "self is nil" do
      it "returns {}" do
        expect(nil.as_hash).to eq({})
      end # returns {}
    end # self is nil
    
    context "self responds to #to_h" do
      
      context "#to_h succeeds" do
        it "returns result of #to_h" do
          expect([[:a, 1], [:b, 2]].as_hash).to eq({a: 1, b: 2})
        end # returns result of #to_h
      end # #to_h succeeds
      
      context "#to_h fails" do
        it "returns hash with self keyed as `key`" do
          expect([1, 2, 3].as_hash(:a)).to eq({a: [1, 2, 3]})
        end # returns hash with self keyed as `key`
        
        context "no key provided" do
          it "raises ArgumentError" do
            expect { [1, 2, 3].as_hash }.to raise_error ArgumentError
          end # raises ArgumentErrpr
        end # no key provided
        it "raises ArgumentErrpr" do
          
        end # raises ArgumentErrpr
      end # #to_h failsexpect { [1, 2, 3].as_hash }.to raise_error ArgumentError
      
    end # self responds to #to_h
    
  end # #as_hash
  
  
  describe '#as_array' do
    context "self is nil" do
      it "returns {}" do
        expect(nil.as_array).to eq([])
      end # returns {}
    end # self is nil
    
  end # #as_array
  
  
end # Refinements for Object
