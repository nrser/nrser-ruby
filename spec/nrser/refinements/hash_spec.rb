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
