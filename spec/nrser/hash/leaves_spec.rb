require 'spec_helper'

describe "NRSER.leaves" do
  subject { NRSER.method :leaves }
  
  it_behaves_like "function",
    mapping: {
      [{a: 1, b: 2}] => {[:a] => 1, [:b] => 2},
      
      [{
        a: {
          x: 'ex',
          y: {
            z: 'zee'
          }
        },
        b: 'bee',  
      }] => {
        [:a, :x] => 'ex',
        [:a, :y, :z] => 'zee',
        [:b] => 'bee',
      },  
    }
  
end # NRSER.bury
