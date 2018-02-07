require 'spec_helper'

using NRSER

describe 'Refinement Hash#map_values' do
  it do
    expect(
      {x: 1, y: 2}.map_values { |key, value| value + 1 }
    ).to eq(
      {x: 2, y: 3}
    )
  end
end # 'Hash#map_values'


describe 'Refinement Hash#find_bounded' do
  subject { {a: 1, b: 2, c: 3} }
  
  it do
    expect(
      subject.find_bounded(length: 2) { |k, v| v >= 2 }
    ).to eq [[:b, 2], [:c, 3]]
    
    expect {
      subject.find_bounded(length: 2) { |k, v| v == 2 }
    }.to raise_error TypeError
  end
end # Refinement Hash#map_values


describe 'Refinement Hash#find_only' do
  subject { {a: 1, b: 2, c: 3} }
  
  it do
    expect(
      subject.find_only { |k, i| i == 2 }
    ).to eq [:b, 2]
    
    expect {
      subject.find_only { |k, i| i >= 2 }
    }.to raise_error TypeError
  end
end # Refinement Hash#map_values


describe "Refinement Hash#leaves" do
  subject { {a: 1, b: 2, c: 3}.leaves }
  
  it { is_expected.to eq( {[:a] => 1, [:b] => 2, [:c] => 3}) }
end # Refinement Hash#leaves


describe "Refinement Hash#each_branch" do
  let( :abc_hash ) { {a: 1, b: 2, c: 3} }
  
  context "called with no block" do
    subject { abc_hash.each_branch }
    
    it {
      is_expected.to be_a( Enumerator ).
        and have_attributes size: 3
    }
  end # called with no block
  
  context "called with a block" do
    subject {
      result = {}
      abc_hash.each_branch { |key, value|
        result[key] = value * value
      }
      result
    }
    
    it { is_expected.to eq(a: 1, b: 4, c: 9) }
  end # called with a block
  
end # Refinement Hash#each_branch
