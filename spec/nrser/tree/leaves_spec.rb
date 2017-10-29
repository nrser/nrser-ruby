require 'spec_helper'

describe "NRSER.leaves" do
  subject { NRSER.method :leaves }
  
  it_behaves_like "function",
    mapping: {
      # flat hash
      [{a: 1, b: 2}] => {[:a] => 1, [:b] => 2},
      
      # flat array
      [ [:a, :b, :c] ] => {
        [0] => :a,
        [1] => :b,
        [2] => :c,
      },
      
      # Nested, all hashes
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
  
end # NRSER.leaves

describe "NRSER.map_leaves" do
  let( :source ) {
    {
      1 => {
        name: 'Neil',
        likes: ['tacos', 'cats'],
      },
      
      2 => {
        name: 'Mica',
        likes: ['cats', 'cookies'],
      },
    }
  }
  
  subject {
    NRSER.map_leaves( source ) { |key_path, value|
      case value
      when 'tacos'
        'tamales'
      when 'cats'
        'bats'
      when 'cookies'
        'wookies'
      else
        value
      end
    }    
  }
  
  it {
    is_expected.to eq({
      1 => {
        name: 'Neil',
        likes: ['tamales', 'bats'],
      },
      
      2 => {
        name: 'Mica',
        likes: ['bats', 'wookies'],
      },
    })
  }
  
end # NRSER.map_leaves

