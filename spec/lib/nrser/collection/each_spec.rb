require 'spec_helper'

describe "NRSER.each" do
  it "iterates enumerables" do
    [
      [1, 2, 3],
      Set.new([1, 2, 3]),
      {a: 1, b: 2, c: 3},
    ].each do |enumerable|
      count = 0
      NRSER.each enumerable do |element|
        count += 1
      end
      expect(count).to eq enumerable.count
    end
  end
  
  [
    "abc",
    1,
    Pathname.new('.').expand_path,
    File.open('/dev/null'),
  ].each do |obj|
    it "iterates a single #{ obj.class }" do
      count = 0
      NRSER.each obj do |element|
        expect(element).to eq obj
        count += 1
      end
      expect(count).to eq 1
    end
  end
end