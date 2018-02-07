require 'spec_helper'

describe "NRSER.map" do
  it "maps enumerables" do
    [
      [1, 2, 3],
      Set.new([1, 2, 3]),
      {a: 1, b: 2, c: 3},
    ].each do |enumerable|
      count = 0
      result = NRSER.map enumerable do |element|
        count += 1
        :x
      end
      expect(count).to eq enumerable.count
      expect(result).to eq enumerable.map {|_| :x}
    end
  end
  
  [
    "abc",
    1,
    Pathname.new('.').expand_path,
    File.open('/dev/null'),
  ].map do |obj|
    it "iterates a single #{ obj.class }" do
      count = 0
      result = NRSER.map obj do |element|
        expect(element).to eq obj
        count += 1
        :x
      end
      expect(count).to eq 1
      expect(result).to eq :x
    end
  end
end