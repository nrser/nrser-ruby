require 'spec_helper'

using NRSER

describe 'Refinement Array#map_values' do
  it do
    expect(
      [:x, :y].map_values { |value| "Yo I'm #{ value }!" }
    ).to eq(
      {x: "Yo I'm x!", y: "Yo I'm y!"}
    )
  end
end # Refinement Array#map_values


describe 'Refinement Array#find_bounded' do
  it do
    expect(
      [1, 2, 3].find_bounded(length: 2) { |i| i >= 2 }
    ).to eq [2, 3]
    
    expect {
      [1, 2, 3].find_bounded(length: 2) { |i| i == 2 }
    }.to raise_error TypeError
  end
end # Refinement Array#map_values


describe 'Refinement Array#find_only' do
  it do
    expect(
      [1, 2, 3].find_only { |i| i == 2 }
    ).to be 2
    
    expect {
      [1, 2, 3].find_only { |i| i >= 2 }
    }.to raise_error TypeError
  end
end # Refinement Array#map_values


describe "Refinement Array#leaves" do
  subject { [:a, :b, :c].leaves }
  
  it { is_expected.to eq( {[0] => :a, [1] => :b, [2] => :c}) }
end # Refinement Array#leaves


describe "Refinement Array#each_branch" do
  let( :abc_array ) { [:a, :b, :c] }
  
  context "called with no block" do
    subject { abc_array.each_branch }
    
    it {
      is_expected.to be_a( Enumerator ).
        and have_attributes size: 3
    }
  end # called with no block
  
  context "called with a block" do
    subject {
      result = {}
      abc_array.each_branch { |key, value|
        result[key] = value
      }
      result
    }
    
    it { is_expected.to eq(0 => :a, 1 => :b, 2 => :c) }
  end # called with a block
  
end # Refinement Array#each_branch
