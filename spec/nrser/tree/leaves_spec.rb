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
      
      # Mixed arrays and hashes
      [{
        1 => {
          name: 'Neil',
          likes: ['tacos', 'cats'],
        },
        
        2 => {
          name: 'Mica',
          likes: ['cats', 'cookies'],
        },
      }] => {
        [1, :name]      => 'Neil',
        [1, :likes, 0]  => 'tacos',
        [1, :likes, 1]  => 'cats',
        [2, :name]      => 'Mica',
        [2, :likes, 0]  => 'cats',
        [2, :likes, 1]  => 'cookies',
      },
      
      # Sets should be considered leaves
      [{
        neil: {
          name: 'Neil',
          likes: Set['tacos', 'cats'],
        },
      }] => {
        [:neil, :name]  => 'Neil',
        [:neil, :likes] => Set['tacos', 'cats'],
      },
    } # mapping
  
end # NRSER.bury
