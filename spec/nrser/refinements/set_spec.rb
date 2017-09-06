require 'spec_helper'

using NRSER

describe 'Refinement Set#map_values' do
  it do
    expect(
      Set[:x, :y].map_values { |value| "Yo I'm #{ value }!" }
    ).to eq(
      {x: "Yo I'm x!", y: "Yo I'm y!"}
    )
  end
end # Refinement Set#map_values

describe 'Refinement Set#find_bounded' do
  subject { Set[1, 2, 3] }
  
  it do
    expect(
      subject.find_bounded(length: 2) { |i| i >= 2 }
    ).to eq [2, 3]
    
    expect {
      subject.find_bounded(length: 2) { |i| i == 2 }
    }.to raise_error TypeError
  end
end # Refinement Set#map_values

describe 'Refinement Set#find_only' do
  subject { Set[1, 2, 3] }
  
  it do
    expect(
      subject.find_only { |i| i == 2 }
    ).to be 2
    
    expect {
      subject.find_only { |i| i >= 2 }
    }.to raise_error TypeError
  end
end # Refinement Set#map_values
