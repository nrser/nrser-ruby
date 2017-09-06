require 'spec_helper'

describe "NRSER Enumerable Methods" do
  
  describe NRSER.method(:find_bounded) do
    
    context "when just :length bounds arg is provided" do
      it "returns found elements when length is correct" do
        expect(
          subject.([1, 2, 3], length: 1) { |i| i == 2 }
        ).to eq [2]
      end
      
      it "raises TypeError when length in incorrect" do
        expect {
          subject.([1, 2, 3], length: 2) { |i| i == 2 }
        }.to raise_error TypeError
      end
    end # when just :length bounds arg is provided
    
    context "when just :min bounds arg is provided" do
      it "returns found elements when min is correct" do
        expect(
          subject.([1, 2, 3], min: 1) { |i| i == 2 }
        ).to eq [2]
      end
      
      it "raises TypeError when min in incorrect" do
        expect {
          subject.([1, 2, 3], min: 2) { |i| i == 2 }
        }.to raise_error TypeError
      end
    end # when just :min bounds arg is provided

    context "when just :max bounds arg is provided" do
      it "returns found elements when max is correct" do
        expect(
          subject.([1, 2, 3], max: 2) { |i| i >= 2 }
        ).to eq [2, 3]
      end
      
      it "raises TypeError when max in incorrect" do
        expect {
          subject.([1, 2, 3], max: 1) { |i| i >= 2 }
        }.to raise_error TypeError
      end
    end # when just :max bounds arg is provided
    
    
    context "when :min and :max bounds args are both provided" do
      it "returns found elements when min and max are correct" do
        expect(
          subject.([1, 2, 3], min: 1, max: 2) { |i| i >= 2 }
        ).to eq [2, 3]
      end
      
      it "raises TypeError when min is incorrect" do
        expect {
          subject.([1, 2, 3], min: 1, max: 2) { |i| false }
        }.to raise_error TypeError
      end
      
      it "raises TypeError when max is incorrect" do
        expect {
          subject.([1, 2, 3], min: 1, max: 2) { |i| true }
        }.to raise_error TypeError
      end
    end # when :min and :max bounds args are both provided
    
  end # NRSER.method(:find_bounded)
  
  
  describe NRSER.method(:find_only) do
    
    it "returns the element when only one is found" do
      expect(
        subject.call [1, 2, 3] { |i| i == 2 }
      ).to be 2
    end
    
    it "raises TypeError when more than one element is found" do
      expect {
        subject.call [1, 2, 3] { |i| i >= 2 }
      }.to raise_error TypeError
    end
    
    it "raises TypeError when no elements are found" do
      expect {
        subject.call [1, 2, 3] { |i| false }
      }.to raise_error TypeError
    end
    
  end # NRSER.method(:find_only)
  
  
end # NRSER Enumerable Methods

