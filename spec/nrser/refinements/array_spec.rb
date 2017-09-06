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
