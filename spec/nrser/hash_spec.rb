require 'spec_helper'

using NRSER

describe NRSER.method(:truncate) do
  it do
    expect(NRSER.leaves({a: 1, b: 2})).to eq ({[:a] => 1, [:b] => 2})
    expect(
      NRSER.leaves({
        a: {
          x: 'ex',
          y: {
            z: 'zee'
          }
        },
        b: 'bee',
      })
    ).to eq({
      [:a, :x] => 'ex',
      [:a, :y, :z] => 'zee',
      [:b] => 'bee',
    })
  end
end # truncate
