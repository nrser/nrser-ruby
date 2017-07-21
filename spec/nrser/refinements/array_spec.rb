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
end # Array#map_values
