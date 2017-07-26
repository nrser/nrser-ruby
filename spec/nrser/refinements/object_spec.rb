require 'spec_helper'

using NRSER

describe "Refinements for Object" do
  
  describe '#as_hash' do
    
    it "returns itself when self is a hash" do
      expect({a: 1}.as_hash(:a)).to eq({a: 1})
    end # returns itself when self is a hash
    
    context "self responds to #to_h" do
      
      context "#to_h succeeds" do
        it "returns result of #to_h" do
          expect([[:a, 1], [:b, 2]].as_hash(:a)).to eq({a: 1, b: 2})
        end # returns result of #to_h
      end # #to_h succeeds
      
      context "#to_h fails" do
        it "returns hash with self keyed as `key`" do
          expect([1, 2, 3].as_hash(:a)).to eq({a: [1, 2, 3]})
        end # returns hash with self keyed as `key`
      end # #to_h fails
      
    end # self responds to #to_h
    
  end # #as_hash
  
  
end # Refinements for Object
