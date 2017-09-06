require 'spec_helper'

describe "NRSER Enumerable Methods" do
  
  describe NRSER.method(:find_bounded) do
    
    it "works with a correct length" do
      expect(
        subject.([1, 2, 3], length: 1) { |i| i == 2 }
      ).to eq [2]
    end
    
    it "fails with an incorrect length" do
      expect {
        subject.([1, 2, 3], length: 2) { |i| i == 2 }
      }.to raise_error TypeError
    end
    
    it "works with a correct min" do
      expect(
        subject.([1, 2, 3], min: 1) { |i| i == 2 }
      ).to eq [2]
    end
    
    it "fails with an incorrect min" do
      expect {
        subject.([1, 2, 3], min: 2) { |i| i == 2 }
      }.to raise_error TypeError
    end
    
    it "works with a correct max" do
      expect(
        subject.([1, 2, 3], max: 2) { |i| i >= 2 }
      ).to eq [2, 3]
    end
    
    it "fails with an incorrect max" do
      expect {
        subject.([1, 2, 3], max: 1) { |i| i >= 2 }
      }.to raise_error TypeError
    end
    
  end # NRSER.method(:find_bounded)
  
end # NRSER Enumerable Methods

